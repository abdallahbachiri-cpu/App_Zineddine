<?php

namespace App\Controller\V2;

use App\Controller\Abstract\BaseController;
use App\Entity\Enum\OrderStatus;
use App\Entity\Order;
use App\Entity\User;
use App\Service\Order\OrderService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use OpenApi\Attributes as OA;

#[Route('/api/seller/food-store/orders', name: 'seller_food_store_orders_')]
class SellerFoodStoreOrderController extends BaseController
{
    public function __construct(
        private OrderService $orderService,
        private EntityManagerInterface $entityManager
    ) {
    }

    #[Route('/{id}/ready', name: 'ready', methods: ['POST'])]
    #[OA\Post(
        summary: "Mark an order as ready for delivery",
        description: "Marks a confirmed order as ready and notifies the buyer.",
        tags: ["Seller - Food Store - Orders"],
    )]
    public function markOrderAsReady(string $id): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $foodStore = $user->getFoodStore();
        if (!$foodStore) {
            return $this->json(['error' => 'Food store not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $order = $this->orderService->getOrderById($id);

        if (!$order instanceof Order || $order->getStore() !== $foodStore) {
            throw new NotFoundHttpException('Order not found or does not belong to your food store');
        }

        if ($order->getStatus() !== OrderStatus::Confirmed) {
            return $this->json(['error' => 'Only confirmed orders can be marked as ready.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $order->setStatus(OrderStatus::Ready);
        $this->entityManager->persist($order);
        $this->entityManager->flush();

        // Notify Buyer
        $this->orderService->createAndSendNotification(
            $user,
            $order->getBuyer(),
            'Order is Ready',
            'Your order ' . $order->getOrderNumber() . ' is ready! You can go and take it.',
            'Commande prete',
            'Votre commande ' . $order->getOrderNumber() . ' est prete ! Vous pouvez passer la recuperer.',
            $order->getId()
        );

        return $this->json([
            'message' => 'Order marked as ready.',
            'orderId' => $order->getId(),
            'status' => $order->getStatus()->value
        ], JsonResponse::HTTP_OK);
    }
}
