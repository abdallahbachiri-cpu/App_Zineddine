<?php

namespace App\Controller\Support;

use App\Controller\Abstract\BaseController;
use App\Entity\User;
use App\Service\Mailer\MailService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

/**
 * POST /api/support/contact
 * Sends a contact email to support and a confirmation to the sender.
 */
#[Route('/api/support', name: 'support_contact_')]
class ContactController extends BaseController
{
    private const SUPPORT_EMAIL = 'info@cuisinous.ca';

    public function __construct(
        private MailService $mailService,
    ) {}

    #[Route('/contact', name: 'contact', methods: ['POST'])]
    public function contact(Request $request): JsonResponse
    {
        /** @var User|null $sender */
        $sender = $this->getUser();

        $data     = json_decode($request->getContent(), true);
        $subject  = trim($data['subject'] ?? '');
        $body     = trim($data['message'] ?? '');
        $userType = $data['userType'] ?? 'user';

        if ($subject === '' || strlen($body) < 20) {
            return $this->json(
                ['error' => 'Subject and message (min 20 chars) are required.'],
                Response::HTTP_BAD_REQUEST
            );
        }

        $senderEmail = $sender?->getEmail() ?? ($data['email'] ?? 'anonymous@cuisinous.ca');
        $senderName  = $sender
            ? $sender->getFirstName() . ' ' . $sender->getLastName()
            : ($data['name'] ?? 'Utilisateur anonyme');

        $typeLabel = match ($userType) {
            'seller' => 'Vendeur',
            'buyer'  => 'Client',
            default  => 'Utilisateur',
        };

        // ── Email to support ─────────────────────────────────────────────────
        $supportHtml = sprintf(
            '<p><strong>Nouveau message de contact</strong></p>
            <table cellpadding="6" style="border-collapse:collapse;font-family:sans-serif;font-size:14px">
              <tr><td><strong>De</strong></td><td>%s (%s)</td></tr>
              <tr><td><strong>Type de compte</strong></td><td>%s</td></tr>
              <tr><td><strong>Sujet</strong></td><td>%s</td></tr>
            </table>
            <p style="margin-top:16px"><strong>Message :</strong></p>
            <div style="background:#f9f9f9;padding:12px;border-left:4px solid #F97316;font-family:sans-serif;font-size:14px">%s</div>',
            htmlspecialchars($senderName),
            htmlspecialchars($senderEmail),
            htmlspecialchars($typeLabel),
            htmlspecialchars($subject),
            nl2br(htmlspecialchars($body))
        );

        try {
            $this->mailService->send(
                self::SUPPORT_EMAIL,
                '[Cuisinous Support] ' . $subject,
                $supportHtml
            );
        } catch (\RuntimeException $e) {
            // Log already handled inside MailService; return 202 so the UI isn't blocked
        }

        // ── Confirmation to sender ────────────────────────────────────────────
        $confirmHtml = sprintf(
            '<p>Bonjour %s,</p>
            <p>Nous avons bien reçu votre message concernant : <strong>%s</strong></p>
            <p>Notre équipe de support vous répondra dans les plus brefs délais à l\'adresse <strong>%s</strong>.</p>
            <p style="margin-top:24px">— L\'équipe Cuisinous</p>',
            htmlspecialchars($senderName),
            htmlspecialchars($subject),
            htmlspecialchars($senderEmail)
        );

        try {
            $this->mailService->send(
                $senderEmail,
                'Cuisinous — Votre message a bien été reçu',
                $confirmHtml
            );
        } catch (\RuntimeException $e) {
            // Confirmation failure is non-fatal
        }

        return $this->json(['message' => 'Votre message a été envoyé avec succès.']);
    }
}
