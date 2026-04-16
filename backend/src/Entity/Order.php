<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Entity\Enum\OrderDeliveryMethod;
use App\Entity\Enum\OrderDeliveryStatus;
use App\Entity\Enum\OrderPaymentStatus;
use App\Entity\Enum\OrderStatus;
use App\Entity\Enum\OrderTipPaymentStatus;
use App\Helper\MoneyHelper;
use App\Repository\OrderRepository;
use Brick\Math\BigDecimal;
use DateTimeImmutable;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: OrderRepository::class)]
#[ORM\Table(name: '`orders`')]
class Order extends BaseEntity
{
    public const SEARCHABLE_FIELDS = ['orderNumber'];
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'orderNumber', 'totalPrice'];

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false)]
    private User $buyer;

    #[ORM\ManyToOne(targetEntity: Cart::class)]
    #[ORM\JoinColumn(nullable: false)]
    private Cart $cart;

    #[ORM\ManyToOne(targetEntity: FoodStore::class)]
    #[ORM\JoinColumn(nullable: false)]
    private FoodStore $foodStore;

    #[ORM\Column(length: 3)]
    private string $currency = 'CAD';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $totalPrice; // total price before tax

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $taxTotal = '0.00'; // total tax amount

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    private string $grossTotal; // total price after tax

    #[ORM\Column(type: 'json')]
    private array $appliedTaxes = [];

    #[ORM\Column(type: 'string', length: 6, nullable: false)]
    private string $confirmationCode;

    #[ORM\Column(type: 'string', unique: true)]
    private string $orderNumber;

    #[ORM\Column(enumType: OrderStatus::class, options: ["default" => "pending"])]
    private OrderStatus $status = OrderStatus::Pending;

    #[ORM\Column(enumType: OrderPaymentStatus::class, options: ["default" => "pending"])]
    private OrderPaymentStatus $paymentStatus = OrderPaymentStatus::Pending;

    #[ORM\Column(enumType: OrderDeliveryStatus::class, options: ["default" => "pending"])]
    private OrderDeliveryStatus $deliveryStatus = OrderDeliveryStatus::Pending;

    #[ORM\ManyToOne(targetEntity: Location::class, cascade: ['persist'])]
    #[ORM\JoinColumn(nullable: false)]
    private Location $location;

    #[ORM\OneToMany(mappedBy: 'order', targetEntity: OrderDish::class, cascade: ['persist', 'remove'])]
    private Collection $dishes;

    #[ORM\OneToMany(mappedBy: 'order', targetEntity: DishRating::class)]
    private Collection $dishRatings;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $buyerNote = null;


    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $paymentMethod = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?DateTimeImmutable $paidAt = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    private ?string $paidAmount = null;
    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $paymentCurrency = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripePaymentIntentId = null;
    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripeSessionId = null;

    // // PayPal
    // private ?string $paypalOrderId;
    // private ?string $paypalTransactionId;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?DateTimeImmutable $refundedAt = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $stripeRefundId = null;

    #[ORM\Column(enumType: OrderDeliveryMethod::class, options: ["default" => "pickup"])]
    private OrderDeliveryMethod $deliveryMethod = OrderDeliveryMethod::Pickup;


    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $twilioSessionSid = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $twilioBuyerParticipantSid = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $twilioSellerParticipantSid = null;


    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    private ?string $tipAmount = null;

    #[ORM\Column(type: 'string', nullable: true)]
    private ?string $tipStripePaymentIntentId = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?DateTimeImmutable $tipPaidAt = null;

    #[ORM\Column(enumType: OrderTipPaymentStatus::class, nullable: true)]
    private ?OrderTipPaymentStatus $tipPaymentStatus = null;


    public function __construct(User $buyer, Cart $cart, FoodStore $foodStore, Location $location)
    {
        $this->buyer = $buyer;
        $this->cart = $cart;
        $this->foodStore = $foodStore;
        $this->location = $location;
        // $this->totalPrice = $totalPrice;
        $this->dishes = new ArrayCollection();
        $this->confirmationCode = $this->generateConfirmationCode();
        $this->orderNumber = $this->generateOrderNumber();
        $this->dishRatings = new ArrayCollection();
    }

    public function getBuyer(): User
    {
        return $this->buyer;
    }

    public function setBuyer(User $buyer): self
    {
        $this->buyer = $buyer;
        return $this;
    }

    public function getCart(): Cart
    {
        return $this->cart;
    }

    public function setCart(Cart $cart): self
    {
        $this->cart = $cart;
        return $this;
    }

    public function getStore(): FoodStore
    {
        return $this->foodStore;
    }

    public function setStore(FoodStore $foodStore): self
    {
        $this->foodStore = $foodStore;
        return $this;
    }

    public function getTotalPrice(): string
    {
        return $this->totalPrice;
    }

    public function getDecimalTotalPrice(): BigDecimal
    {
        return BigDecimal::of($this->totalPrice);
    }

    public function setTotalPrice(float|string $price): self
    {
        $this->totalPrice = MoneyHelper::normalize((float) abs($price));
        return $this;
    }

    public function getStatus(): OrderStatus
    {
        return $this->status;
    }

    public function setStatus(OrderStatus $status): self
    {
        $this->status = $status;
        return $this;
    }

    public function getPaymentStatus(): OrderPaymentStatus
    {
        return $this->paymentStatus;
    }

    public function setPaymentStatus(OrderPaymentStatus $paymentStatus): self
    {
        $this->paymentStatus = $paymentStatus;
        return $this;
    }

    public function getDeliveryStatus(): OrderDeliveryStatus
    {
        return $this->deliveryStatus;
    }

    public function setDeliveryStatus(OrderDeliveryStatus $deliveryStatus): self
    {
        $this->deliveryStatus = $deliveryStatus;
        return $this;
    }


    public function getLocation(): Location
    {
        return $this->location;
    }

    public function setLocation(Location $location): self
    {
        $this->location = $location;
        return $this;
    }

    public function getDishes(): Collection
    {
        return $this->dishes;
    }

    public function addDish(OrderDish $dish): self
    {
        if (!$this->dishes->contains($dish)) {
            $this->dishes[] = $dish;
            $dish->setOrder($this);
        }
        return $this;
    }

    public function removeDish(OrderDish $dish): self
    {
        $this->dishes->removeElement($dish);
        return $this;
    }

    public function getConfirmationCode(): string
    {
        return $this->confirmationCode;
    }

    public function setConfirmationCode(string $confirmationCode): self
    {
        $this->confirmationCode = $confirmationCode;
        return $this;
    }

    public function getOrderNumber(): string
    {
        return $this->orderNumber;
    }

    public function setOrderNumber(string $orderNumber): self
    {
        $this->orderNumber = $orderNumber;
        return $this;
    }

    private function generateConfirmationCode(): string
    {
        return (string) random_int(100000, 999999);
    }

    private function generateOrderNumber(): string
    {
        return 'ORDER-' . date('Ymd') . strtoupper(substr(bin2hex(random_bytes(3)), 0, 6));
    }

    public function getDishRatings(): Collection
    {
        return $this->dishRatings;
    }

    public function getBuyerNote(): ?string
    {
        return $this->buyerNote;
    }

    public function setBuyerNote(?string $buyerNote): self
    {
        $this->buyerNote = $buyerNote;

        return $this;
    }

    public function getCurrency(): string
    {
        return $this->currency;
    }

    public function setCurrency(string $currency): self
    {
        $this->currency = $currency;
        return $this;
    }



    // Payment fields:

    public function getPaymentMethod(): ?string
    {
        return $this->paymentMethod;
    }

    public function setPaymentMethod(?string $paymentMethod): self
    {
        $this->paymentMethod = $paymentMethod;
        return $this;
    }

    public function getPaidAt(): ?DateTimeImmutable
    {
        return $this->paidAt;
    }

    public function setPaidAt(?DateTimeImmutable $paidAt): self
    {
        $this->paidAt = $paidAt;
        return $this;
    }

    public function getPaidAmount(): ?string
    {
        return $this->paidAmount;
    }

    public function setPaidAmount(float|string|null $amount): self
    {
        if ($amount === null) {
            $this->paidAmount = null;
        } else {
            $this->paidAmount = MoneyHelper::normalize((float) abs($amount));
        }
        return $this;
    }

    public function getPaymentCurrency(): ?string
    {
        return $this->paymentCurrency;
    }

    public function setPaymentCurrency(?string $paymentCurrency): self
    {
        $this->paymentCurrency = $paymentCurrency;
        return $this;
    }

    // Stripe fields:

    public function getStripePaymentIntentId(): ?string
    {
        return $this->stripePaymentIntentId;
    }

    public function setStripePaymentIntentId(?string $stripePaymentIntentId): self
    {
        $this->stripePaymentIntentId = $stripePaymentIntentId;
        return $this;
    }

    public function getStripeSessionId(): ?string
    {
        return $this->stripeSessionId;
    }

    public function setStripeSessionId(?string $stripeSessionId): self
    {
        $this->stripeSessionId = $stripeSessionId;
        return $this;
    }


    public function getRefundedAt(): ?DateTimeImmutable
    {
        return $this->refundedAt;
    }

    public function setRefundedAt(DateTimeImmutable $refundedAt): self
    {
        $this->refundedAt = $refundedAt;
        return $this;
    }

    public function getStripeRefundId(): ?string
    {
        return $this->stripeRefundId;
    }

    public function setStripeRefundId(?string $stripeRefundId): self
    {
        $this->stripeRefundId = $stripeRefundId;
        return $this;
    }

    public function getDeliveryMethod(): OrderDeliveryMethod
    {
        return $this->deliveryMethod;
    }

    public function setDeliveryMethod(OrderDeliveryMethod $deliveryMethod): self
    {
        $this->deliveryMethod = $deliveryMethod;
        return $this;
    }

    public function getTipAmount(): ?string
    {
        return $this->tipAmount;
    }

    public function setTipAmount(?string $tipAmount): self
    {
        $this->tipAmount = $tipAmount;
        return $this;
    }

    public function getTwilioSessionSid(): ?string
    {
        return $this->twilioSessionSid;
    }

    public function setTwilioSessionSid(?string $twilioSessionSid): self
    {
        $this->twilioSessionSid = $twilioSessionSid;
        return $this;
    }

    public function getTwilioBuyerParticipantSid(): ?string
    {
        return $this->twilioBuyerParticipantSid;
    }

    public function setTwilioBuyerParticipantSid(?string $twilioBuyerParticipantSid): self
    {
        $this->twilioBuyerParticipantSid = $twilioBuyerParticipantSid;
        return $this;
    }

    public function getTwilioSellerParticipantSid(): ?string
    {
        return $this->twilioSellerParticipantSid;
    }

    public function setTwilioSellerParticipantSid(?string $twilioSellerParticipantSid): self
    {
        $this->twilioSellerParticipantSid = $twilioSellerParticipantSid;
        return $this;
    }

    public function getTipStripePaymentIntentId(): ?string
    {
        return $this->tipStripePaymentIntentId;
    }

    public function setTipStripePaymentIntentId(?string $tipStripePaymentIntentId): self
    {
        $this->tipStripePaymentIntentId = $tipStripePaymentIntentId;
        return $this;
    }

    public function getTipPaidAt(): ?DateTimeImmutable
    {
        return $this->tipPaidAt;
    }

    public function setTipPaidAt(?DateTimeImmutable $tipPaidAt): self
    {
        $this->tipPaidAt = $tipPaidAt;
        return $this;
    }

    public function getTipPaymentStatus(): ?OrderTipPaymentStatus
    {
        return $this->tipPaymentStatus;
    }

    public function setTipPaymentStatus(?OrderTipPaymentStatus $tipPaymentStatus): self
    {
        $this->tipPaymentStatus = $tipPaymentStatus;
        return $this;
    }

    public function getTaxTotal(): string
    {
        return $this->taxTotal;
    }

    public function setTaxTotal(string $taxTotal): self
    {
        $this->taxTotal = $taxTotal;
        return $this;
    }

    public function getGrossTotal(): string
    {
        return $this->grossTotal;
    }

    public function setGrossTotal(string $grossTotal): self
    {
        $this->grossTotal = $grossTotal;
        return $this;
    }

    public function getAppliedTaxes(): array
    {
        return $this->appliedTaxes;
    }

    public function setAppliedTaxes(array $appliedTaxes): self
    {
        $this->appliedTaxes = $appliedTaxes;
        return $this;
    }
}
