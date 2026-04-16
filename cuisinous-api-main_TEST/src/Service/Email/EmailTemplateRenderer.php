<?php

namespace App\Service\Email;

use App\Entity\User;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Contracts\Translation\TranslatorInterface;
use Twig\Environment;

class EmailTemplateRenderer
{
    public function __construct(
        private Environment $twig,
        private TranslatorInterface $translator
    ) {}

    public function render(string $templateName, array $context, string $locale): string
    {
        $context['_locale'] = $locale;
        return $this->twig->render($templateName, $context);
    }
    
    public function renderPasswordResetEmail(User $user, string $resetLink, string $locale): array
    {
        // $this->translator->setLocale($locale);
        $context = [
            'user' => $user,
            'resetLink' => $resetLink,
            'locale' => $locale,
            // 'trans_params' => [
            //     'domain' => 'messages',
            //     '_locale' => $locale
            // ]
        ];

        // dd($context);
        
        return [
            'html' => $this->twig->render('emails/password_reset.html.twig', $context),
            'text' => $this->twig->render('emails/password_reset.txt.twig', $context)
        ];
    }
    
    public function renderOrderConfirmationEmail(
        string $locale,
        object $user,
        object $order
    ): array {
        $context = [
            'user' => $user,
            'order' => $order,
            'locale' => $locale,
            // 'trans_params' => [
            //     'domain' => 'messages',
            //     '_locale' => $locale
            // ]
        ];
        
        return [
            'html' => $this->twig->render('emails/order_confirmation_code.html.twig', $context),
            'text' => $this->twig->render('emails/order_confirmation_code.txt.twig', $context)
        ];
    }

    public function renderEmailConfirmationEmail(
        string $locale,
        User $user,
        string $token
    ): array {
        $context = [
            'user' => $user,
            'locale' => $locale,
            'emailConfirmationToken' => $token
        ];

        
        return [
            'html' => $this->twig->render('emails/email_confirmation.html.twig', $context),
            'text' => $this->twig->render('emails/email_confirmation.txt.twig', $context)
        ];
    }
}