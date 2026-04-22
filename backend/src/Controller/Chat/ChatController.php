<?php

namespace App\Controller\Chat;

use App\Controller\Abstract\BaseController;
use App\Entity\ChatMessage;
use App\Entity\Enum\OrderStatus;
use App\Entity\Order;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/chat', name: 'chat_')]
class ChatController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $em,
    ) {}

    /**
     * GET /api/chat/{orderId}
     * Returns all messages for a given order.
     * Accessible only to the buyer and the seller of the order.
     */
    #[Route('/{orderId}', name: 'get_messages', methods: ['GET'])]
    public function getMessages(string $orderId): JsonResponse
    {
        /** @var User $currentUser */
        $currentUser = $this->getUser();
        if (!$currentUser instanceof User) {
            return $this->json(['error' => 'Unauthorized'], Response::HTTP_UNAUTHORIZED);
        }

        $order = $this->em->getRepository(Order::class)->find($orderId);
        if (!$order instanceof Order) {
            return $this->json(['error' => 'Order not found'], Response::HTTP_NOT_FOUND);
        }

        if (!$this->canAccessChat($order, $currentUser)) {
            return $this->json(['error' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        $messages = $this->em->getRepository(ChatMessage::class)->findBy(
            ['order' => $order],
            ['createdAt' => 'ASC']
        );

        return $this->json(array_map(fn(ChatMessage $m) => $this->serializeMessage($m), $messages));
    }

    /**
     * POST /api/chat/{orderId}
     * Sends a message in a conversation linked to an order.
     */
    #[Route('/{orderId}', name: 'send_message', methods: ['POST'])]
    public function sendMessage(string $orderId, Request $request): JsonResponse
    {
        /** @var User $sender */
        $sender = $this->getUser();
        if (!$sender instanceof User) {
            return $this->json(['error' => 'Unauthorized'], Response::HTTP_UNAUTHORIZED);
        }

        $order = $this->em->getRepository(Order::class)->find($orderId);
        if (!$order instanceof Order) {
            return $this->json(['error' => 'Order not found'], Response::HTTP_NOT_FOUND);
        }

        if (!$this->canAccessChat($order, $sender)) {
            return $this->json(['error' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        $data = json_decode($request->getContent(), true) ?? [];
        $text = trim($data['message'] ?? '');
        if ($text === '') {
            return $this->json(['error' => 'Message cannot be empty'], Response::HTTP_BAD_REQUEST);
        }

        // Determine receiver: if sender is buyer → receiver is seller (store owner), else buyer
        $buyer  = $order->getBuyer();
        $seller = $order->getStore()->getSeller();
        $receiver = $sender->getId() === $buyer->getId() ? $seller : $buyer;

        $chatMessage = new ChatMessage();
        $chatMessage->setOrder($order);
        $chatMessage->setSender($sender);
        $chatMessage->setReceiver($receiver);
        $chatMessage->setMessage($text);

        $this->em->persist($chatMessage);
        $this->em->flush();

        $payload = $this->serializeMessage($chatMessage);

        // Publish to Mercure hub
        $this->publishToMercure("/chat/{$orderId}", $payload);

        return $this->json($payload, Response::HTTP_CREATED);
    }

    /**
     * PUT /api/chat/{orderId}/read
     * Marks all unread messages for the current user as read.
     */
    #[Route('/{orderId}/read', name: 'mark_read', methods: ['PUT'])]
    public function markAsRead(string $orderId): JsonResponse
    {
        /** @var User $currentUser */
        $currentUser = $this->getUser();
        if (!$currentUser instanceof User) {
            return $this->json(['error' => 'Unauthorized'], Response::HTTP_UNAUTHORIZED);
        }

        $order = $this->em->getRepository(Order::class)->find($orderId);
        if (!$order instanceof Order) {
            return $this->json(['error' => 'Order not found'], Response::HTTP_NOT_FOUND);
        }

        if (!$this->canAccessChat($order, $currentUser)) {
            return $this->json(['error' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        // Mark messages where receiver = currentUser as read
        $this->em->createQuery(
            'UPDATE App\Entity\ChatMessage m SET m.isRead = true
             WHERE m.order = :order AND m.receiver = :user AND m.isRead = false'
        )
            ->setParameter('order', $order)
            ->setParameter('user', $currentUser)
            ->execute();

        return $this->json(['message' => 'Messages marked as read']);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private function canAccessChat(Order $order, User $user): bool
    {
        // Chat is only available once the seller has confirmed the order
        $allowedStatuses = [OrderStatus::Confirmed, OrderStatus::Ready, OrderStatus::Completed];
        if (!in_array($order->getStatus(), $allowedStatuses, true)) {
            return false;
        }

        $buyerId  = $order->getBuyer()->getId();
        $sellerId = $order->getStore()->getSeller()->getId();
        $userId   = $user->getId();

        $roles = $user->getRoles();
        return $userId === $buyerId
            || $userId === $sellerId
            || in_array('ROLE_ADMIN', $roles, true)
            || in_array('ROLE_SUPPORT', $roles, true);
    }

    private function serializeMessage(ChatMessage $m): array
    {
        return [
            'id'           => $m->getId(),
            'orderId'      => $m->getOrder()->getId(),
            'senderId'     => $m->getSender()->getId(),
            'senderName'   => $m->getSender()->getFirstName() . ' ' . $m->getSender()->getLastName(),
            'receiverId'   => $m->getReceiver()->getId(),
            'message'      => $m->getMessage(),
            'isRead'       => $m->isRead(),
            'createdAt'    => $m->getCreatedAt()?->format(\DateTimeInterface::ATOM),
        ];
    }

    /**
     * Publish a payload to the Mercure hub via HTTP POST.
     * Uses the MERCURE_JWT_SECRET env var to sign a publisher JWT.
     */
    private function publishToMercure(string $topic, array $data): void
    {
        $hubUrl = $_ENV['MERCURE_URL'] ?? 'http://localhost:3001/.well-known/mercure';
        $secret = $_ENV['MERCURE_JWT_SECRET'] ?? 'CuisinousSecretKey2024!';

        $jwt = $this->buildPublisherJwt($secret);

        $ch = curl_init($hubUrl);
        curl_setopt_array($ch, [
            CURLOPT_POST           => true,
            CURLOPT_POSTFIELDS     => http_build_query([
                'topic' => $topic,
                'data'  => json_encode($data),
            ]),
            CURLOPT_HTTPHEADER     => [
                'Authorization: Bearer ' . $jwt,
                'Content-Type: application/x-www-form-urlencoded',
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => 3,
        ]);
        curl_exec($ch);
        curl_close($ch);
    }

    private function buildPublisherJwt(string $secret): string
    {
        $header  = $this->base64Url(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
        $payload = $this->base64Url(json_encode([
            'mercure' => ['publish' => ['*']],
            'iat'     => time(),
            'exp'     => time() + 60,
        ]));
        $sig = $this->base64Url(hash_hmac('sha256', "{$header}.{$payload}", $secret, true));
        return "{$header}.{$payload}.{$sig}";
    }

    private function base64Url(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
