<?php

namespace App\Controller\Support;

use App\Controller\Abstract\BaseController;
use App\Entity\ChatMessage;
use App\Entity\Order;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

/**
 * Support agent endpoints — accessible to ROLE_ADMIN and ROLE_SUPPORT.
 */
#[Route('/api/support', name: 'support_')]
class SupportController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $em,
    ) {}

    /**
     * GET /api/support/conversations
     * Returns every order that has at least one chat message.
     */
    #[Route('/conversations', name: 'conversations', methods: ['GET'])]
    public function conversations(): JsonResponse
    {
        /** @var User $agent */
        $agent = $this->getUser();
        if (!$agent instanceof User || !$this->isAgentOrAdmin($agent)) {
            return $this->json(['error' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        // All orders that have chat messages, most recent first
        $rows = $this->em->createQueryBuilder()
            ->select('o.id AS orderId, o.orderNumber, o.status,
                      b.id AS buyerId, b.firstName AS buyerFirst, b.lastName AS buyerLast,
                      s.id AS sellerId, s.firstName AS sellerFirst, s.lastName AS sellerLast,
                      COUNT(cm.id) AS messageCount,
                      SUM(CASE WHEN cm.isRead = false THEN 1 ELSE 0 END) AS unreadCount,
                      MAX(cm.createdAt) AS lastMessageAt')
            ->from(Order::class, 'o')
            ->join('o.buyer', 'b')
            ->join('o.store', 'store')
            ->join('store.seller', 's')
            ->join(ChatMessage::class, 'cm', 'WITH', 'cm.order = o')
            ->groupBy('o.id, o.orderNumber, o.status, b.id, b.firstName, b.lastName, s.id, s.firstName, s.lastName')
            ->orderBy('lastMessageAt', 'DESC')
            ->getQuery()
            ->getArrayResult();

        return $this->json($rows);
    }

    /**
     * GET /api/support/conversations/{orderId}
     * Returns all messages for a specific conversation.
     */
    #[Route('/conversations/{orderId}', name: 'conversation_detail', methods: ['GET'])]
    public function conversationDetail(string $orderId): JsonResponse
    {
        /** @var User $agent */
        $agent = $this->getUser();
        if (!$agent instanceof User || !$this->isAgentOrAdmin($agent)) {
            return $this->json(['error' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        $order = $this->em->getRepository(Order::class)->find($orderId);
        if (!$order instanceof Order) {
            return $this->json(['error' => 'Order not found'], Response::HTTP_NOT_FOUND);
        }

        $messages = $this->em->getRepository(ChatMessage::class)->findBy(
            ['order' => $order],
            ['createdAt' => 'ASC']
        );

        return $this->json(array_map(fn(ChatMessage $m) => [
            'id'         => $m->getId(),
            'orderId'    => $m->getOrder()->getId(),
            'senderId'   => $m->getSender()->getId(),
            'senderName' => $m->getSender()->getFirstName() . ' ' . $m->getSender()->getLastName(),
            'receiverId' => $m->getReceiver()->getId(),
            'message'    => $m->getMessage(),
            'isRead'     => $m->isRead(),
            'createdAt'  => $m->getCreatedAt()?->format(\DateTimeInterface::ATOM),
        ], $messages));
    }

    /**
     * POST /api/support/reply/{orderId}
     * Allows a support agent to post a message in an order conversation.
     */
    #[Route('/reply/{orderId}', name: 'reply', methods: ['POST'])]
    public function reply(string $orderId, Request $request): JsonResponse
    {
        /** @var User $agent */
        $agent = $this->getUser();
        if (!$agent instanceof User || !$this->isAgentOrAdmin($agent)) {
            return $this->json(['error' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        $order = $this->em->getRepository(Order::class)->find($orderId);
        if (!$order instanceof Order) {
            return $this->json(['error' => 'Order not found'], Response::HTTP_NOT_FOUND);
        }

        $data    = json_decode($request->getContent(), true);
        $text    = trim($data['message'] ?? '');
        $toId    = $data['receiverId'] ?? null;

        if ($text === '') {
            return $this->json(['error' => 'Message cannot be empty'], Response::HTTP_BAD_REQUEST);
        }

        // Receiver: if specified use it, otherwise default to the buyer
        $receiver = $toId
            ? $this->em->getRepository(User::class)->find($toId)
            : $order->getBuyer();

        if (!$receiver instanceof User) {
            return $this->json(['error' => 'Receiver not found'], Response::HTTP_NOT_FOUND);
        }

        $msg = new ChatMessage();
        $msg->setOrder($order);
        $msg->setSender($agent);
        $msg->setReceiver($receiver);
        $msg->setMessage($text);

        $this->em->persist($msg);
        $this->em->flush();

        return $this->json([
            'id'         => $msg->getId(),
            'senderId'   => $agent->getId(),
            'senderName' => $agent->getFirstName() . ' ' . $agent->getLastName(),
            'receiverId' => $receiver->getId(),
            'message'    => $msg->getMessage(),
            'createdAt'  => $msg->getCreatedAt()?->format(\DateTimeInterface::ATOM),
        ], Response::HTTP_CREATED);
    }

    private function isAgentOrAdmin(User $user): bool
    {
        $roles = $user->getRoles();
        return in_array('ROLE_ADMIN', $roles, true)
            || in_array('ROLE_SUPPORT', $roles, true);
    }
}
