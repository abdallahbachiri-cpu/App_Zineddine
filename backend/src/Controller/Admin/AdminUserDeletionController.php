<?php

namespace App\Controller\Admin;

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

#[Route('/api/admin', name: 'admin_user_deletion_')]
class AdminUserDeletionController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
    ) {}

    #[Route('/users/{id}', name: 'delete_user', methods: ['DELETE'])]
    #[OA\Delete(
        summary: 'Delete a user account (admin)',
        description: 'Permanently deletes a user account and all associated data. Cannot delete admin accounts.',
        tags: ['Admin - Users'],
        responses: [
            new OA\Response(response: 200, description: 'User deleted successfully'),
            new OA\Response(response: 403, description: 'Cannot delete admin account'),
            new OA\Response(response: 404, description: 'User not found'),
            new OA\Response(response: 401, description: 'Unauthorized'),
        ]
    )]
    public function deleteUser(string $id): JsonResponse
    {
        /** @var User $admin */
        $admin = $this->getUser();
        if (!$admin instanceof User) {
            return $this->json(['error' => 'Unauthorized'], Response::HTTP_UNAUTHORIZED);
        }

        $target = $this->entityManager->getRepository(User::class)->find($id);
        if (!$target instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }

        if ($target->getType() === User::TYPE_ADMIN || in_array('ROLE_ADMIN', $target->getRoles(), true)) {
            return $this->json(['error' => 'Cannot delete admin account'], Response::HTTP_FORBIDDEN);
        }

        $em = $this->entityManager;

        // 1. Delete notifications (sender or receiver)
        $em->createQuery(
            'DELETE FROM ' . Notification::class . ' n WHERE n.sender = :user OR n.receiver = :user'
        )->setParameter('user', $target)->execute();

        // 2. Delete orders (cascades DishRatings via onDelete: CASCADE)
        $orders = $em->getRepository(Order::class)->findBy(['buyer' => $target]);
        foreach ($orders as $order) {
            $em->remove($order);
        }
        $em->flush();

        // 3. Delete refresh tokens
        $em->createQuery(
            'DELETE FROM ' . RefreshToken::class . ' rt WHERE rt.user = :user'
        )->setParameter('user', $target)->execute();

        // 4. Delete password reset tokens
        $em->createQuery(
            'DELETE FROM ' . PasswordResetToken::class . ' prt WHERE prt.user = :user'
        )->setParameter('user', $target)->execute();

        // 5. Delete the user
        $em->remove($target);
        $em->flush();

        return $this->json(['message' => 'User deleted successfully'], Response::HTTP_OK);
    }
}
