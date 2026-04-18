<?php

namespace App\Controller\Vendor;

use App\Controller\Abstract\BaseController;
use App\Entity\User;
use App\Service\User\UserMapper;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/vendor', name: 'vendor_contract_')]
class VendorContractController extends BaseController
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private UserMapper $userMapper
    ) {}

    /**
     * POST /api/vendor/sign-contract
     * Marks the authenticated seller as having signed the vendor contract.
     */
    #[Route('/sign-contract', name: 'sign', methods: ['POST'])]
    public function signContract(Request $request): JsonResponse
    {
        $this->denyAccessUnlessGranted('ROLE_SELLER');

        /** @var User $user */
        $user = $this->getUser();

        if ($user->isHasSignedVendorContract()) {
            // Already signed — return current state (idempotent)
            return $this->json([
                'message'               => 'Contract already signed.',
                'hasSignedVendorContract' => true,
                'contractSignedAt'      => $user->getContractSignedAt()?->format('Y-m-d\TH:i:sP'),
                'user'                  => $this->userMapper->mapToDTO($user),
            ]);
        }

        $user->setHasSignedVendorContract(true);
        $user->setContractSignedAt(new \DateTimeImmutable());

        // Also accept on the food store if one exists
        $foodStore = $user->getFoodStore();
        if ($foodStore !== null && !$foodStore->isVendorAgreementAccepted()) {
            $foodStore->setVendorAgreementAccepted(true);
            $foodStore->setVendorAgreementAcceptedAt(new \DateTimeImmutable());
        }

        $this->entityManager->flush();

        return $this->json([
            'message'               => 'Contract signed successfully.',
            'hasSignedVendorContract' => true,
            'contractSignedAt'      => $user->getContractSignedAt()?->format('Y-m-d\TH:i:sP'),
            'user'                  => $this->userMapper->mapToDTO($user),
        ]);
    }
}
