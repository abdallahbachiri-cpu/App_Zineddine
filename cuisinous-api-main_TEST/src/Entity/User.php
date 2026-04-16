<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\UserRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Notification;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'users')]
class User extends BaseEntity implements UserInterface, PasswordAuthenticatedUserInterface
{
    public const TYPE_BUYER = 'buyer';
    public const TYPE_SELLER = 'seller';
    public const TYPE_ADMIN = 'admin';

    public const SEARCHABLE_FIELDS = ['firstName', 'lastName', 'email', 'phoneNumber'];
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt', 'firstName', 'lastName', 'email'];


    #[ORM\Column(type: 'json')]
    private array $roles = ['ROLE_USER'];

    #[ORM\Column(type: 'boolean')]
    private bool $isActive = true;

    #[ORM\Column(type: 'string', length: 255)]
    private string $firstName;

    #[ORM\Column(type: 'string', length: 255)]
    private string $lastName;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $middleName = null;

    #[ORM\Column(type: 'string', length: 255, unique: true)]
    #[Assert\NotBlank(message: 'Email is required.')]
    #[Assert\Email(message: 'The email "{{ value }}" is not a valid email.')]
    private ?string $email = null;

    #[ORM\Column(type: 'string', length: 50, nullable: true)]
    private ?string $type = null; // 'buyer', 'seller', 'admin'

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    #[Assert\Regex('/^\+?[0-9]+$/', message: "Invalid phone number format.")]
    private ?string $phoneNumber = null;

    #[ORM\Column(type: 'boolean')]
    private bool $isPhoneConfirmed = false;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $phoneConfirmationToken = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $phoneConfirmedAt = null;

    #[ORM\Column(type: 'boolean')]
    private bool $isEmailConfirmed = false;

    #[ORM\Column(type: 'string', length: 6, nullable: true)]
    private ?string $emailConfirmationToken = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $emailConfirmedAt = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $emailConfirmationTokenExpiresAt = null;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $password = null;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $googleId = null;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $appleId = null;

    #[ORM\Column(type: 'datetime_immutable', nullable: true)]
    private ?\DateTimeImmutable $deletedAt = null;

    #[ORM\OneToOne(mappedBy: 'seller', targetEntity: FoodStore::class, cascade: ['persist', 'remove'])]
    private $foodStore;

    #[ORM\OneToMany(mappedBy: 'user', targetEntity: Location::class)]
    private Collection $addresses;

    #[ORM\ManyToOne(targetEntity: Location::class, fetch: 'EAGER')]
    #[ORM\JoinColumn(name: "default_address_id", referencedColumnName: "id", nullable: true)]
    private ?Location $defaultAddress = null;

    #[ORM\OneToMany(mappedBy: 'buyer', targetEntity: DishRating::class)]
    private Collection $dishRatings;

    #[ORM\ManyToOne(targetEntity: Media::class, cascade: ['persist'])]
    #[ORM\JoinColumn(nullable: true, onDelete: 'SET NULL')]
    private ?Media $profileImage = null;

    #[ORM\Column(type: 'string', length: 2, options: ['default' => 'en'])]
    private string $locale = 'en';

    #[ORM\Column(type: 'boolean', nullable: true, options: ['default' => null])]
    private ?bool $isGoogleOnboardingCompleted = null;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $fcmToken = null;
    #[ORM\OneToMany(mappedBy: 'receiver', targetEntity: Notification::class, cascade: ['persist', 'remove'])]
    private Collection $receivedNotifications;
    #[ORM\OneToMany(mappedBy: 'sender', targetEntity: Notification::class, cascade: ['persist', 'remove'])]
    private Collection $sentNotifications;

    public function __construct()
    {
        $this->addresses = new ArrayCollection();
        $this->dishRatings = new ArrayCollection();
        $this->receivedNotifications = new ArrayCollection();
        $this->sentNotifications = new ArrayCollection();
    }

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function setActive(bool $isActive): self
    {
        $this->isActive = $isActive;

        return $this;
    }

    public function suspend(): self
    {
        $this->isActive = false;

        return $this;
    }

    public function activate(): self
    {
        $this->isActive = true;

        return $this;
    }

    public function getFirstName(): string
    {
        return $this->firstName;
    }

    public function setFirstName(string $firstName): self
    {
        $this->firstName = $firstName;

        return $this;
    }

    public function getLastName(): string
    {
        return $this->lastName;
    }

    public function setLastName(string $lastName): self
    {
        $this->lastName = $lastName;

        return $this;
    }

    public function getMiddleName(): ?string
    {
        return $this->middleName;
    }

    public function setMiddleName(?string $middleName): self
    {
        $this->middleName = $middleName;

        return $this;
    }

    public function getFullName(): string
    {
        $parts = array_filter([
            $this->firstName,
            $this->middleName,
            $this->lastName,
        ]);

        return implode(' ', $parts);
    }


    public function getEmail(): string
    {
        return $this->email;
    }

    public function setEmail(string $email): self
    {
        $this->email = $email;

        return $this;
    }


    public function isEmailConfirmed(): bool
    {
        return $this->isEmailConfirmed;
    }

    public function getEmailConfirmationToken(): ?string
    {
        return $this->emailConfirmationToken;
    }

    public function getEmailConfirmedAt(): ?\DateTimeImmutable
    {
        return $this->emailConfirmedAt;
    }

    public function setEmailConfirmed(bool $isEmailConfirmed): self
    {
        $this->isEmailConfirmed = $isEmailConfirmed;

        if ($isEmailConfirmed) {
            $this->emailConfirmedAt = new \DateTimeImmutable();
            $this->emailConfirmationToken = null;
            $this->emailConfirmationTokenExpiresAt = null;
        }

        return $this;
    }

    public function generateEmailConfirmationToken(): string
    {
        $this->emailConfirmationToken = substr(strtoupper(bin2hex(random_bytes(3))), 0, 6);
        $this->emailConfirmationTokenExpiresAt = new \DateTimeImmutable('+30 minutes');
        return $this->emailConfirmationToken;
    }

    public function isEmailConfirmationTokenExpired(): bool
    {
        if (!$this->emailConfirmationTokenExpiresAt) {
            return true;
        }

        return $this->emailConfirmationTokenExpiresAt < new \DateTimeImmutable();
    }


    public function resetEmailConfirmation(): self
    {
        $this->isEmailConfirmed = false;
        $this->emailConfirmationToken = null;
        $this->emailConfirmedAt = null;
        $this->emailConfirmationTokenExpiresAt = null;
        return $this;
    }

    public function verifyEmailConfirmationToken(string $token): bool
    {
        if (!$this->emailConfirmationToken) {
            return false;
        }
        return !$this->isEmailConfirmationTokenExpired() && hash_equals(strtoupper($this->emailConfirmationToken), strtoupper($token));
    }


    public function getType(): ?string
    {
        return $this->type;
    }

    public function setType(?string $type): self
    {
        if ($type !== null) {
            $allowedTypes = self::getAllowedTypes();
            if (!in_array($type, $allowedTypes, true)) {
                $errorMessage = sprintf(
                    "Invalid user type: %s. Allowed types are: %s.",
                    $type,
                    implode(", ", array_map(fn($t) => "'$t'", $allowedTypes))
                );
                throw new \InvalidArgumentException($errorMessage);
            }
        }

        $this->type = $type;

        $this->updateRoles();

        return $this;
    }

    public function getPhoneNumber(): ?string
    {
        return $this->phoneNumber;
    }

    public function setPhoneNumber(string $phoneNumber): static
    {
        // If the phone number is changed, reset the confirmation state
        if ($this->phoneNumber !== $phoneNumber) {
            $this->setPhoneConfirmed(false);
            $this->phoneConfirmedAt = null;
        }

        $this->phoneNumber = $phoneNumber;

        return $this;
    }

    public function isPhoneConfirmed(): bool
    {
        return $this->isPhoneConfirmed;
    }

    public function setPhoneConfirmed(bool $isPhoneConfirmed): self
    {
        $this->isPhoneConfirmed = $isPhoneConfirmed;

        if ($isPhoneConfirmed) {
            $this->phoneConfirmedAt = new \DateTimeImmutable();
            $this->phoneConfirmationToken = null;
        }

        return $this;
    }

    public function getPhoneConfirmationToken(): ?string
    {
        return $this->phoneConfirmationToken;
    }

    public function setPhoneConfirmationToken(?string $phoneConfirmationToken): self
    {
        $this->phoneConfirmationToken = $phoneConfirmationToken;

        return $this;
    }

    public function getPhoneConfirmedAt(): ?\DateTimeImmutable
    {
        return $this->phoneConfirmedAt;
    }

    public function setPhoneConfirmedAt(?\DateTimeImmutable $phoneConfirmedAt): self
    {
        $this->phoneConfirmedAt = $phoneConfirmedAt;

        return $this;
    }

    public function getPassword(): ?string
    {
        return $this->password;
    }

    public function setPassword(string $password): static
    {
        $this->password = $password;

        return $this;
    }

    public function getGoogleId(): ?string
    {
        return $this->googleId;
    }

    public function setGoogleId(?string $googleId): static
    {
        $this->googleId = $googleId;

        return $this;
    }

    public function getAppleId(): ?string
    {
        return $this->appleId;
    }

    public function setAppleId(?string $appleId): static
    {
        $this->appleId = $appleId;

        return $this;
    }

    public function isGoogleOnboardingCompleted(): ?bool
    {
        return $this->isGoogleOnboardingCompleted;
    }

    public function setIsGoogleOnboardingCompleted(?bool $isGoogleOnboardingCompleted): self
    {
        $this->isGoogleOnboardingCompleted = $isGoogleOnboardingCompleted;
        return $this;
    }



    public function getUserIdentifier(): string
    {
        // return $this->id->toString();
        return $this->email;
    }

    public function eraseCredentials(): void
    {
    }

    public function getRoles(): array
    {
        return array_unique(array_merge($this->roles, ['ROLE_USER']));  // Ensure ROLE_USER is always included
    }

    /**
     * Update the roles based on the user type.
     */
    private function updateRoles(): void
    {
        // Start with the default ROLE_USER for all authenticated users
        $roles = ['ROLE_USER'];

        // Add the role based on the user type
        switch ($this->type) {
            case self::TYPE_ADMIN:
                $roles[] = 'ROLE_ADMIN';
                break;
            case self::TYPE_SELLER:
                $roles[] = 'ROLE_SELLER';
                break;
            case self::TYPE_BUYER:
                // default:
                $roles[] = 'ROLE_BUYER';
                break;
        }

        // Ensure the roles array contains only unique roles
        $this->roles = array_unique($roles);
    }

    public function setRoles(array $roles): self
    {
        $this->roles = array_unique($roles);
        return $this;
    }

    public function getDeletedAt(): ?\DateTimeImmutable
    {
        return $this->deletedAt;
    }

    public function setDeletedAt(?\DateTimeImmutable $deletedAt): self
    {
        $this->deletedAt = $deletedAt;

        return $this;
    }

    public function isDeleted(): bool
    {
        return $this->deletedAt !== null;
    }

    //active and not soft deleted
    public function isAvailable(): bool
    {
        return $this->isActive && $this->deletedAt === null;
    }


    #[ORM\PreRemove]
    public function softDelete(): void
    {
        $this->deletedAt = new \DateTimeImmutable();
    }

    /**
     * Restore a soft-deleted user by clearing the `deletedAt` timestamp.
     */
    public function restore(): self
    {
        $this->deletedAt = null;
        return $this;
    }


    public static function getAllowedTypes(): array
    {
        return [
            self::TYPE_BUYER,
            self::TYPE_SELLER,
            self::TYPE_ADMIN,
        ];
    }

    public function getFoodStore(): ?FoodStore
    {
        return $this->foodStore;
    }

    public function setFoodStore(FoodStore $foodStore): self
    {
        // Ensure the relationship is properly bidirectional
        $this->foodStore = $foodStore;
        $foodStore->setSeller($this);

        return $this;
    }

    public function getAddresses(): Collection
    {
        return $this->addresses;
    }

    public function addAddress(Location $address): self
    {
        if (!$this->addresses->contains($address)) {
            $this->addresses->add($address);
            $address->setUser($this);
        }

        return $this;
    }

    public function removeAddress(Location $address): self
    {
        if ($this->defaultAddress && $this->defaultAddress === $address) {
            $this->setDefaultAddress(null);
        }

        $this->addresses->removeElement($address);

        return $this;
    }

    public function getDefaultAddress(): ?Location
    {
        return $this->defaultAddress;
    }

    public function setDefaultAddress(?Location $defaultAddress): self
    {
        $this->defaultAddress = $defaultAddress;
        return $this;
    }

    public function getDishRatings(): Collection
    {
        return $this->dishRatings;
    }

    public function getProfileImage(): ?Media
    {
        return $this->profileImage;
    }

    public function setProfileImage(?Media $profileImage): self
    {
        $this->profileImage = $profileImage;
        return $this;
    }

    public function getLocale(): string
    {
        return $this->locale;
    }

    public function setLocale(string $locale): self
    {
        $this->locale = $locale;
        return $this;
    }

    public function needsGoogleOnboarding(): bool
    {
        $isOAuthUser = $this->googleId !== null || $this->appleId !== null;
        return $isOAuthUser && $this->isGoogleOnboardingCompleted !== true;
    }
    public function getFcmToken(): ?string
    {
        return $this->fcmToken;
    }

    public function setFcmToken(?string $fcmToken): self
    {
        $this->fcmToken = $fcmToken;
        return $this;
    }

    /**
     * @return Collection<int, Notification>
     */
    public function getReceivedNotifications(): Collection
    {
        return $this->receivedNotifications;
    }

    /**
     * @return Collection<int, Notification>
     */
    public function getSentNotifications(): Collection
    {
        return $this->sentNotifications;
    }

}