<?php

namespace App\Controller\Payment;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/stripe', name: 'stripe_')]
class StripeController extends AbstractController
{
    public function __construct(
        private readonly string $onboardingFrontendReturnUrl,
        private readonly string $onboardingFrontendRefreshUrl,

    ) {}

    #[Route('/onboarding/return', name: 'onboarding_return', methods: ['GET'])]
    public function onboardingReturn(): RedirectResponse
    {
        return $this->redirect($this->onboardingFrontendReturnUrl);
    }

    #[Route('/onboarding/refresh', name: 'onboarding_refresh', methods: ['GET'])]
    public function onboardingRefresh(): RedirectResponse
    {
        return $this->redirect($this->onboardingFrontendRefreshUrl);
    }
}
