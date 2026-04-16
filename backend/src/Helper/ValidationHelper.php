<?php

namespace App\Helper;

use Ramsey\Uuid\Uuid;
use Symfony\Component\Validator\ConstraintViolation;
use Symfony\Component\Validator\ConstraintViolationListInterface;

class ValidationHelper
{
    public const MAXIMUM_ALLOWED_CART_DISH_QUANTITY = 50;
    public const MAXIMUM_ALLOWED_CART_DISH_INGREDIENT_QUANTITY = 30;
    private const ALLOWED_EMAIL_DOMAINS = [
        'gmail.com',
        'yahoo.com',
        'outlook.com',
        'hotmail.com',
        'live.com',
        'icloud.com',
        'me.com',
        'msn.com',
        'aol.com',

        // privacy providers
        'proton.me',
        'protonmail.com',
        'pm.me',

        // others
        'zoho.com',
        'yandex.com',
        'mail.com',
        'gmx.com',
        'gmx.net',

        // Canadian ISPs
        'rogers.com',
        'bell.net',
        'sympatico.ca',
        'shaw.ca',
        'telus.net',
        'videotron.ca',
        'cogeco.ca',
        'eastlink.ca',
        'mts.net',
        'sasktel.net'
    ];

    public static function trimFields(array &$data, array $whiteList = []): void
    {
        foreach ($data as $key => $value) {
            if (!in_array($key, $whiteList) && is_string($value)) {
                $data[$key] = trim($value);
            }
        }
    }

    public static function formatErrors(ConstraintViolationListInterface $violations): array
    {
        $errorMessages = [];

        foreach ($violations as $violation) {
            if ($violation instanceof ConstraintViolation) {
                $field = $violation->getPropertyPath();
                $errorMessages[] = sprintf("%s: %s", $field, $violation->getMessage());
            }
        }

        return $errorMessages;
    }

    public static function isCorrectUuid(mixed $id): bool
    {
        return is_string($id) && Uuid::isValid($id);
    }

    public function normalizeEmail(string $email): string
    {
        $email = trim(mb_strtolower($email));

        if ($this->isGoogleDomain($email)) {
            [$local, $domain] = explode('@', $email, 2);
            $local = str_replace('.', '', $local);
            $local = explode('+', $local)[0];
            $email = $local . '@gmail.com';
        }

        return $email;
    }

    private function isGoogleDomain(string $email): bool
    {
        return (bool)preg_match('/@(gmail|googlemail)\.com$/i', $email);
    }

    public function isAllowedEmailDomain(string $email): bool
    {
        $domain = substr(strrchr($email, "@"), 1);

        return in_array($domain, self::ALLOWED_EMAIL_DOMAINS, true);
    }

    // public function validateJsonPayload(Request $request): ?array
    // {
    //     $data = json_decode($request->getContent(), true);
    //     if (json_last_error() !== JSON_ERROR_NONE || !is_array($data)) {
    //         return null;
    //     }
    //     return $data;
    // }

}
