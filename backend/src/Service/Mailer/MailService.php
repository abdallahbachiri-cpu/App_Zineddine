<?php
namespace App\Service\Mailer;

use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Psr\Log\LoggerInterface;
use Symfony\Component\Mailer\Exception\TransportExceptionInterface;

class MailService
{
    public function __construct(
        private MailerInterface $mailer,
        private LoggerInterface $logger,
        private string $defaultFrom
    ) {}

    /**
     * @throws \RuntimeException When email sending fails
    */
    public function send(string $to, string $subject, string $htmlBody, ?string $textBody = null): void
    {
        $email = (new Email())
            ->from($this->defaultFrom)
            ->to($to)
            ->subject($subject)
            ->html($htmlBody);

        if ($textBody) {
            $email->text($textBody);
        }

        try {
            $this->mailer->send($email);

        } catch (TransportExceptionInterface $e) {
            $this->logger->error('Email sending failed', [
                'exception' => $e,
                'to' => $to,
                'subject' => $subject,
            ]);

            //dev
            throw new \RuntimeException('Failed to send email: ' . $e->getMessage(), 0, $e);
            // throw new \RuntimeException('Failed to send the email');
        }
    }
}
