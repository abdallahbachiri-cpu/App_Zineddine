<?php

namespace App\Controller\Abstract;

use App\Entity\User;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class BaseController extends AbstractController
{
    protected function getRequestData(Request $request): ?array
    {
        // Check if the request is JSON
        if ($request->headers->get('Content-Type') === 'application/json') {
            $data = json_decode($request->getContent(), true);
            if (json_last_error() !== JSON_ERROR_NONE || !is_array($data)) {
                return null;
            }
            return $data;
        }

        // If not JSON, assume multipart/form-data
        return array_merge($request->request->all(), $request->files->all());
    }

    protected function getLocale(Request $request): string
    {
        $user = $this->getUser();
        if ($user instanceof User && in_array($user->getLocale(), ['en', 'fr'])) {
            return $user->getLocale();
        }
        $locale = $request->headers->get('X-Locale');

        if (!$locale) {
            $locale = $request->getPreferredLanguage(['en', 'fr']);
        }

        if (!$locale) {
            $locale = $request->query->get('locale');
        }

        if (!$locale) {
            $locale = $request->request->get('locale');
        }

        return in_array($locale, ['en', 'fr'])
            ? $locale
            : $this->getParameter('default_locale');
    }
}
