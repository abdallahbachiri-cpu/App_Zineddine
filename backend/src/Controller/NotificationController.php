<?php

namespace App\Controller;

use App\Controller\Abstract\BaseController;
use App\Entity\Notification;
use App\Entity\User;
use App\Repository\NotificationRepository;
use App\Repository\UserRepository;
use App\Service\Fcm\FcmNotificationService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Annotation\Model;

#[Route('/api/notifications')]
#[OA\Tag(name: "Notifications")]
class NotificationController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private NotificationRepository $notificationRepository,
        private UserRepository $userRepository,
        private FcmNotificationService $fcmNotificationService
    ) {}

    #[Route('', name: 'notification_create', methods: ['POST'])]
    #[OA\Post(
        summary: "Create a single notification",
        requestBody: new OA\RequestBody(
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "receiverId", type: "string", format: "uuid"),
                    new OA\Property(property: "senderId", type: "string", format: "uuid"),
                    new OA\Property(property: "title", type: "string"),
                    new OA\Property(property: "body", type: "string"),
                    new OA\Property(property: "title_fr", type: "string", nullable: true),
                    new OA\Property(property: "body_fr", type: "string", nullable: true),
                ],
                required: ["receiverId", "senderId", "title", "body"]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: "Notification created"),
            new OA\Response(response: 400, description: "Invalid input"),
            new OA\Response(response: 404, description: "Sender or Receiver not found")
        ]
    )]
    public function create(Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);
        if (!$data || !isset($data['receiverId'], $data['senderId'], $data['title'], $data['body'])) {
            return $this->json(['error' => 'Missing required fields (receiverId, senderId, title, body)'], Response::HTTP_BAD_REQUEST);
        }

        $sender = $this->userRepository->find($data['senderId']);
        $receiver = $this->userRepository->find($data['receiverId']);

        if (!$sender) {
            return $this->json(['error' => 'Sender not found'], Response::HTTP_NOT_FOUND);
        }
        if (!$receiver) {
            return $this->json(['error' => 'Receiver not found'], Response::HTTP_NOT_FOUND);
        }

        $notification = new Notification();
        $notification->setTitle($data['title']);
        $notification->setBody($data['body']);
        $notification->setTitleFr($data['title_fr'] ?? null);
        $notification->setBodyFr($data['body_fr'] ?? null);
        $notification->setSender($sender);
        $notification->setReceiver($receiver);
        $notification->setIsShow(false);

        $this->entityManager->persist($notification);
        $this->entityManager->flush();

        if ($receiver->getFcmToken()) {
            try {
                // Send push notification (uses title/body based on logic in service or default)
                // Note: FcmNotificationService might need updates to support locale-based title/body if needed
                $this->fcmNotificationService->sendNotification(
                    $receiver->getFcmToken(),
                    $notification->getTitle(),
                    $notification->getBody()
                );
            } catch (\Exception $e) {
                // Notification stored in DB, but push failed. We don't fail the request.
            }
        }

        return $this->json([
            'message' => 'Notification created successfully',
            'id' => $notification->getId()
        ], Response::HTTP_CREATED);
    }

    #[Route('/bulk', name: 'notification_bulk_create', methods: ['POST'])]
    #[IsGranted('ROLE_ADMIN')]
    #[OA\Post(
        summary: "Bulk create notifications (Admin only)",
        requestBody: new OA\RequestBody(
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "receiverIds", type: "array", items: new OA\Items(type: "string", format: "uuid")),
                    new OA\Property(property: "senderId", type: "string", format: "uuid"),
                    new OA\Property(property: "title", type: "string"),
                    new OA\Property(property: "body", type: "string"),
                    new OA\Property(property: "title_fr", type: "string", nullable: true),
                    new OA\Property(property: "body_fr", type: "string", nullable: true),
                ],
                required: ["receiverIds", "senderId", "title", "body"]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: "Notifications created"),
            new OA\Response(response: 400, description: "Invalid input"),
            new OA\Response(response: 403, description: "Forbidden")
        ]
    )]
    public function bulkCreate(Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);
        if (!$data || !isset($data['receiverIds'], $data['senderId'], $data['title'], $data['body'])) {
            return $this->json(['error' => 'Missing required fields (receiverIds, senderId, title, body)'], Response::HTTP_BAD_REQUEST);
        }

        if (!is_array($data['receiverIds'])) {
            return $this->json(['error' => 'receiverIds must be an array'], Response::HTTP_BAD_REQUEST);
        }

        $sender = $this->userRepository->find($data['senderId']);
        if (!$sender) {
            return $this->json(['error' => 'Sender not found'], Response::HTTP_NOT_FOUND);
        }

        $count = 0;
        foreach ($data['receiverIds'] as $receiverId) {
            $receiver = $this->userRepository->find($receiverId);
            if ($receiver) {
                $notification = new Notification();
                $notification->setTitle($data['title']);
                $notification->setBody($data['body']);
                $notification->setTitleFr($data['title_fr'] ?? null);
                $notification->setBodyFr($data['body_fr'] ?? null);
                $notification->setSender($sender);
                $notification->setReceiver($receiver);
                $notification->setIsShow(false);

                $this->entityManager->persist($notification);
                $count++;

                if ($receiver->getFcmToken()) {
                    try {
                        $this->fcmNotificationService->sendNotification(
                            $receiver->getFcmToken(),
                            $notification->getTitle(),
                            $notification->getBody()
                        );
                    } catch (\Exception $e) {}
                }
            }
        }

        $this->entityManager->flush();

        return $this->json([
            'message' => "Bulk notifications created for $count users"
        ], Response::HTTP_CREATED);
    }

    #[Route('/receiver/{id}', name: 'notification_get_by_receiver', methods: ['GET'])]
    #[OA\Get(
        summary: "Get notifications by receiver ID",
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(response: 200, description: "List of notifications"),
            new OA\Response(response: 404, description: "Receiver not found")
        ]
    )]
    public function getByReceiver(string $id): JsonResponse
    {
        $receiver = $this->userRepository->find($id);
        if (!$receiver) {
            return $this->json(['error' => 'Receiver not found'], Response::HTTP_NOT_FOUND);
        }

        $notifications = $this->notificationRepository->findBy(['receiver' => $receiver], ['createdAt' => 'DESC']);
        
        $data = array_map(function(Notification $n) {
            $sender = $n->getSender();
            return [
                'id' => $n->getId(),
                'title' => $n->getTitle(),
                'body' => $n->getBody(),
                'titleFr' => $n->getTitleFr(),
                'bodyFr' => $n->getBodyFr(),
                'senderId' => $sender->getId(),
                'orderId' => $n->getOrder()?->getId(),
                'sender' => [
                    'id' => $sender->getId(),
                    'firstName' => $sender->getFirstName(),
                    'lastName' => $sender->getLastName(),
                    'email' => $sender->getEmail(),
                ],
                'isShow' => $n->isShow(),
                'createdAt' => $n->getCreatedAt()?->format(\DateTimeInterface::ATOM),
            ];
        }, $notifications);

        return $this->json($data);
    }

    #[Route('/{id}/show', name: 'notification_mark_shown', methods: ['PUT'])]
    #[OA\Put(
        summary: "Mark a notification as shown/read",
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(response: 200, description: "Notification marked as shown"),
            new OA\Response(response: 404, description: "Notification not found")
        ]
    )]
    public function markAsShown(string $id): JsonResponse
    {
        $notification = $this->notificationRepository->find($id);
        if (!$notification) {
            return $this->json(['error' => 'Notification not found'], Response::HTTP_NOT_FOUND);
        }

        $notification->setIsShow(true);
        $this->entityManager->flush();

        return $this->json(['message' => 'Notification marked as shown']);
    }

    #[Route('/{id}', name: 'notification_update', methods: ['PUT'])]
    #[OA\Put(
        summary: "Update notification content",
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        requestBody: new OA\RequestBody(
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "title", type: "string", nullable: true),
                    new OA\Property(property: "body", type: "string", nullable: true),
                    new OA\Property(property: "title_fr", type: "string", nullable: true),
                    new OA\Property(property: "body_fr", type: "string", nullable: true),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: "Notification updated"),
            new OA\Response(response: 404, description: "Notification not found")
        ]
    )]
    public function update(string $id, Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);
        $notification = $this->notificationRepository->find($id);
        
        if (!$notification) {
            return $this->json(['error' => 'Notification not found'], Response::HTTP_NOT_FOUND);
        }

        if (isset($data['title'])) {
            $notification->setTitle($data['title']);
        }
        if (isset($data['body'])) {
            $notification->setBody($data['body']);
        }
        if (isset($data['title_fr'])) {
            $notification->setTitleFr($data['title_fr']);
        }
        if (isset($data['body_fr'])) {
            $notification->setBodyFr($data['body_fr']);
        }

        $this->entityManager->flush();

        return $this->json(['message' => 'Notification updated successfully']);
    }

    #[Route('/{id}', name: 'notification_delete', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete a notification",
        parameters: [
            new OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string", format: "uuid"))
        ],
        responses: [
            new OA\Response(response: 200, description: "Notification deleted"),
            new OA\Response(response: 404, description: "Notification not found")
        ]
    )]
    public function delete(string $id): JsonResponse
    {
        $notification = $this->notificationRepository->find($id);
        if (!$notification) {
            return $this->json(['error' => 'Notification not found'], Response::HTTP_NOT_FOUND);
        }

        $this->entityManager->remove($notification);
        $this->entityManager->flush();

        return $this->json(['message' => 'Notification deleted successfully']);
    }
}
