<?php

namespace App\Service\Twilio;

use App\Entity\Order;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Twilio\Exceptions\RestException;
use Twilio\Rest\Client;

class TwilioProxyService
{
    private Client $twilioClient;
    private EntityManagerInterface $entityManager;
    private LoggerInterface $logger;
    private string $proxyServiceSid;

    private int $twilioProxyTtl = 60 * 90; // 1.5 hours

    // Twilio error codes
    private const TWILIO_POOL_EXHAUSTED = 80623;

    public function __construct(
        string $twilioAccountSid,
        string $twilioAuthToken,
        string $twilioProxyServiceSid,
        EntityManagerInterface $entityManager,
        LoggerInterface $logger
    ) {
        $this->twilioClient = new Client($twilioAccountSid, $twilioAuthToken);
        $this->proxyServiceSid = $twilioProxyServiceSid;
        $this->entityManager = $entityManager;
        $this->logger = $logger;
    }

    /**
     * Get proxy phone numbers for an order.
     * Validates existing session with Twilio, recreates if stale/expired.
     */
    public function getProxyNumbers(Order $order): array
    {
        $sessionSid = $order->getTwilioSessionSid();

        if (!$sessionSid) {
            return $this->createProxySession($order);
        }

        // Validate existing session is still alive on Twilio
        try {
            $session = $this->twilioClient->proxy->v1
                ->services($this->proxyServiceSid)
                ->sessions($sessionSid)
                ->fetch();

            if (in_array($session->status, ['closed', 'failed'], true)) {
                $this->logger->warning('Twilio session is closed/failed, recreating', [
                    'order_id'    => $order->getId(),
                    'session_sid' => $sessionSid,
                    'status'      => $session->status,
                ]);
                return $this->clearAndRecreateSession($order);
            }
        } catch (RestException $e) {
            // 404 = session purged from Twilio entirely
            $this->logger->warning('Twilio session not found, recreating', [
                'order_id'    => $order->getId(),
                'session_sid' => $sessionSid,
                'error'       => $e->getMessage(),
            ]);
            return $this->clearAndRecreateSession($order);
        }

        // Session alive — read participants to get proxy numbers
        try {
            $participants = $this->twilioClient->proxy->v1
                ->services($this->proxyServiceSid)
                ->sessions($sessionSid)
                ->participants
                ->read();
        } catch (RestException $e) {
            $this->logger->error('Failed to read participants, recreating', [
                'order_id'    => $order->getId(),
                'session_sid' => $sessionSid,
                'error'       => $e->getMessage(),
            ]);
            return $this->clearAndRecreateSession($order);
        }

        $buyerProxyNumber  = null;
        $sellerProxyNumber = null;

        foreach ($participants as $participant) {
            $friendlyName = $participant->friendlyName ?? '';
            if (str_starts_with($friendlyName, 'Buyer_')) {
                $buyerProxyNumber = $participant->proxyIdentifier;
            } elseif (str_starts_with($friendlyName, 'Seller_')) {
                $sellerProxyNumber = $participant->proxyIdentifier;
            }
        }

        if (!$buyerProxyNumber || !$sellerProxyNumber) {
            $this->logger->warning('Missing participants in session, recreating', [
                'order_id'    => $order->getId(),
                'session_sid' => $sessionSid,
            ]);
            return $this->clearAndRecreateSession($order);
        }

        $this->logger->info('Proxy numbers returned from existing session', [
            'order_id'            => $order->getId(),
            'session_sid'         => $sessionSid,
            'buyer_proxy_number'  => $buyerProxyNumber,
            'seller_proxy_number' => $sellerProxyNumber,
        ]);

        return [
            'session_sid'         => $sessionSid,
            'buyer_proxy_number'  => $buyerProxyNumber,
            'seller_proxy_number' => $sellerProxyNumber,
        ];
    }

    /**
     * Create a new Twilio proxy session for an order.
     */
    public function createProxySession(Order $order): array
    {
        $session = null;
        try {
            $buyer  = $order->getBuyer();
            $seller = $order->getStore()->getSeller();

            if (!$buyer->getPhoneNumber() || !$seller->getPhoneNumber()) {
                throw new BadRequestHttpException('Both buyer and seller must have phone numbers');
            }

            $buyerPhone  = $this->formatPhoneNumber($buyer->getPhoneNumber());
            $sellerPhone = $this->formatPhoneNumber($seller->getPhoneNumber());

            $uniqueName = 'order_' . $order->getId() . '_' . uniqid('', true);

            $session = $this->twilioClient->proxy->v1
                ->services($this->proxyServiceSid)
                ->sessions->create([
                    'uniqueName' => $uniqueName,
                    'mode'       => 'voice-only',
                    'ttl'        => $this->twilioProxyTtl,
                ]);

            $buyerParticipant = $this->twilioClient->proxy->v1
                ->services($this->proxyServiceSid)
                ->sessions($session->sid)
                ->participants->create($buyerPhone, [
                    'friendlyName' => 'Buyer_' . $buyer->getId(),
                ]);

            $sellerParticipant = $this->twilioClient->proxy->v1
                ->services($this->proxyServiceSid)
                ->sessions($session->sid)
                ->participants->create($sellerPhone, [
                    'friendlyName' => 'Seller_' . $seller->getId(),
                ]);

            $order->setTwilioSessionSid($session->sid);
            $order->setTwilioBuyerParticipantSid($buyerParticipant->sid);
            $order->setTwilioSellerParticipantSid($sellerParticipant->sid);
            $this->entityManager->flush();

            $this->logger->info('Twilio proxy session created', [
                'order_id'            => $order->getId(),
                'session_sid'         => $session->sid,
                'buyer_proxy_number'  => $buyerParticipant->proxyIdentifier,
                'seller_proxy_number' => $sellerParticipant->proxyIdentifier,
            ]);

            return [
                'session_sid'         => $session->sid,
                'buyer_proxy_number'  => $buyerParticipant->proxyIdentifier,
                'seller_proxy_number' => $sellerParticipant->proxyIdentifier,
            ];
        } catch (BadRequestHttpException $e) {
            $this->logger->error('Cannot create proxy session: missing phone numbers', [
                'order_id' => $order->getId(),
                'error'    => $e->getMessage(),
            ]);
            throw $e;
        } catch (RestException $e) {
            $this->cleanupSessionSilently($session, $order->getId());

            if ($e->getCode() === self::TWILIO_POOL_EXHAUSTED) {
                $this->logger->critical('Twilio proxy pool exhausted — add more numbers to the pool', [
                    'order_id' => $order->getId(),
                ]);
                throw new \RuntimeException(
                    'Communication service temporarily unavailable. Please try again shortly.',
                    0,
                    $e
                );
            }

            $this->logger->error('Twilio REST error creating proxy session', [
                'order_id' => $order->getId(),
                'error'    => $e->getMessage(),
                'code'     => $e->getCode(),
            ]);
            throw $e;
        } catch (\Exception $e) {
            $this->cleanupSessionSilently($session, $order->getId());
            $this->logger->error('Failed to create Twilio proxy session', [
                'order_id' => $order->getId(),
                'error'    => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    /**
     * Close the existing session and create a fresh one.
     * Used when an existing session is found to be stale or invalid.
     */
    private function clearAndRecreateSession(Order $order): array
    {
        $this->closeProxySession($order);
        return $this->createProxySession($order);
    }

    /**
     * Close proxy session when order is completed or cancelled.
     * Always clears DB fields regardless of whether Twilio delete succeeds,
     * to prevent dead SIDs from blocking future sessions.
     */
    public function closeProxySession(Order $order): void
    {
        $sessionSid = $order->getTwilioSessionSid();

        if (!$sessionSid) {
            return;
        }

        try {
            $this->twilioClient->proxy->v1
                ->services($this->proxyServiceSid)
                ->sessions($sessionSid)
                ->delete();

            $this->logger->info('Twilio proxy session closed', [
                'order_id'    => $order->getId(),
                'session_sid' => $sessionSid,
            ]);
        } catch (\Exception $e) {
            // Session may already be gone from Twilio — still clear DB below
            $this->logger->warning('Failed to delete Twilio session (may already be gone)', [
                'order_id'    => $order->getId(),
                'session_sid' => $sessionSid,
                'error'       => $e->getMessage(),
            ]);
        } finally {
            // Always clear regardless of Twilio outcome
            $order->setTwilioSessionSid(null);
            $order->setTwilioBuyerParticipantSid(null);
            $order->setTwilioSellerParticipantSid(null);
            $this->entityManager->flush();
        }
    }

    /**
     * Best-effort cleanup of a dangling Twilio session after a failed create.
     */
    private function cleanupSessionSilently(mixed $session, string $orderId): void
    {
        if ($session === null) {
            return;
        }
        try {
            $this->twilioClient->proxy->v1
                ->services($this->proxyServiceSid)
                ->sessions($session->sid)
                ->delete();
        } catch (\Exception $e) {
            $this->logger->error('Failed to cleanup dangling Twilio session', [
                'order_id'    => $orderId,
                'session_sid' => $session->sid,
                'error'       => $e->getMessage(),
            ]);
        }
    }

    /**
     * Format a North American phone number to E.164.
     * TODO: extend for international numbers and move to a PhoneNumberHelper.
     */
    private function formatPhoneNumber(string $phoneNumber): string
    {
        $cleanNumber = preg_replace('/\D/', '', $phoneNumber);

        // E.164 with country code: 11 digits starting with 1
        if (strlen($cleanNumber) === 11 && str_starts_with($cleanNumber, '1')) {
            return '+' . $cleanNumber;
        }

        // 10-digit local number — assume North American (+1)
        if (strlen($cleanNumber) === 10) {
            return '+1' . $cleanNumber;
        }

        throw new \InvalidArgumentException("Invalid North American phone number: {$phoneNumber}");
    }


    /**
     * Create a proxy phone session directly from buyer and seller phone numbers.
     * This is useful for simple testing where an Order entity is not available.
     *
     * @param string $buyerPhone
     * @param string $sellerPhone
     * @return array{session_sid:string,buyer_proxy_number:string,seller_proxy_number:string}
     */
    public function createProxySessionFromNumbers(string $buyerPhone, string $sellerPhone): array
    {
        // dd([$this->formatPhoneNumber($buyerPhone), $this->formatPhoneNumber($sellerPhone)]);
        $session = null;
        try {
            if (!$buyerPhone || !$sellerPhone) {
                throw new BadRequestHttpException('Both buyer and seller must have phone numbers');
            }

            $sessionId = 'dev_test_' . uniqid();

            $session = $this->twilioClient->proxy->v1->services($this->proxyServiceSid)
                ->sessions->create([
                    'uniqueName' => $sessionId,
                    'mode' => 'voice-only',
                    'ttl' => $this->twilioProxyTtl
                ]);

            $buyerParticipant = $this->twilioClient->proxy->v1->services($this->proxyServiceSid)
                ->sessions($session->sid)
                ->participants->create($this->formatPhoneNumber($buyerPhone), [
                    'friendlyName' => 'Buyer_dev',
                    // 'proxyIdentifier' => $this->twilioPhoneNumber
                ]);

            $sellerParticipant = $this->twilioClient->proxy->v1->services($this->proxyServiceSid)
                ->sessions($session->sid)
                ->participants->create($this->formatPhoneNumber($sellerPhone), [
                    'friendlyName' => 'Seller_dev',
                    // 'proxyIdentifier' => $this->twilioPhoneNumber
                ]);

            $this->logger->info('Twilio proxy session created (dev)', [
                'session_sid' => $session->sid,
            ]);

            return [
                'session_sid' => $session->sid,
                'buyer_phone' => $this->formatPhoneNumber($buyerPhone),
                'seller_phone' => $this->formatPhoneNumber($sellerPhone),
                'buyer_proxy_number' => $buyerParticipant->proxyIdentifier,
                'seller_proxy_number' => $sellerParticipant->proxyIdentifier,
            ];
        } catch (\Exception $e) {
            if ($session !== null) {
                try {
                    $this->twilioClient->proxy->v1->services($this->proxyServiceSid)
                        ->sessions($session->sid)
                        ->delete();
                } catch (\Exception $cleanupException) {
                    $this->logger->error('Failed to cleanup Twilio session after error (dev)', [
                        'session_sid' => $session->sid,
                        'cleanup_error' => $cleanupException->getMessage(),
                    ]);
                }
            }

            $this->logger->error('Failed to create Twilio proxy session (dev)', [
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }
}
