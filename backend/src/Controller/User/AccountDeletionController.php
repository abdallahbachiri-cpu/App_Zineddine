<?php

namespace App\Controller\User;

use App\Controller\Abstract\BaseController;
use App\Entity\Notification;
use App\Entity\Order;
use App\Entity\PasswordResetToken;
use App\Entity\RefreshToken;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use OpenApi\Attributes as OA;

#[Route('/api/user', name: 'user_account_')]
class AccountDeletionController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
    ) {}

    #[Route('/account', name: 'delete', methods: ['DELETE'])]
    #[OA\Delete(
        summary: 'Delete the authenticated user account',
        description: 'Permanently deletes the user account and all associated data. Required by Apple App Store guidelines.',
        tags: ['User - account'],
        responses: [
            new OA\Response(response: 200, description: 'Account deleted successfully'),
            new OA\Response(response: 401, description: 'Unauthorized'),
        ]
    )]
    public function deleteAccount(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'Unauthorized'], Response::HTTP_UNAUTHORIZED);
        }

        $em = $this->entityManager;

        // 1. Delete notifications (sender or receiver) — no cascade on User
        $em->createQuery(
            'DELETE FROM ' . Notification::class . ' n WHERE n.sender = :user OR n.receiver = :user'
        )->setParameter('user', $user)->execute();

        // 2. Delete orders where this user is the buyer — cascades DishRatings (onDelete: CASCADE)
        //    First collect order IDs to delete child relations not covered by DB cascade
        $orders = $em->getRepository(Order::class)->findBy(['buyer' => $user]);
        foreach ($orders as $order) {
            $em->remove($order);
        }
        $em->flush();

        // 3. Delete refresh tokens
        $em->createQuery(
            'DELETE FROM ' . RefreshToken::class . ' rt WHERE rt.user = :user'
        )->setParameter('user', $user)->execute();

        // 4. Delete password reset tokens
        $em->createQuery(
            'DELETE FROM ' . PasswordResetToken::class . ' prt WHERE prt.user = :user'
        )->setParameter('user', $user)->execute();

        // 5. Delete the user — DB cascade removes: Cart, CartDish, CartDishIngredient, DishRatings
        $em->remove($user);
        $em->flush();

        return $this->json(['message' => 'Account deleted successfully'], Response::HTTP_OK);
    }
}
