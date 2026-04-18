<?php

namespace App\Controller\Admin;

use App\Controller\Abstract\BaseController;
use App\Repository\FoodStoreRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/admin', name: 'admin_commission_')]
class CommissionController extends BaseController
{
    private const DEFAULT_RATE = 15.0;

    public function __construct(
        private FoodStoreRepository $foodStoreRepository,
        private EntityManagerInterface $entityManager
    ) {}

    /**
     * GET /api/admin/stores/commissions
     * Returns all stores with their individual commission rates.
     */
    #[Route('/stores/commissions', name: 'list', methods: ['GET'])]
    public function listStoreCommissions(): JsonResponse
    {
        $this->denyAccessUnlessGranted('ROLE_ADMIN');

        try {
            $stores = $this->foodStoreRepository->findAll();
        } catch (\Throwable $e) {
            // DB column may not exist yet (migration pending)
            return $this->json([
                'stores' => [],
                'error'  => 'Database error — pending migration: ' . $e->getMessage(),
            ], 500);
        }

        $result = array_map(function ($store) {
            $seller = $store->getSeller();
            // Null-safe: fall back to default rate if column missing in DB
            try {
                $rate = $store->getCommissionRate() ?? self::DEFAULT_RATE;
            } catch (\Throwable) {
                $rate = self::DEFAULT_RATE;
            }

            return [
                'id'             => $store->getId(),
                'name'           => $store->getName(),
                'ownerName'      => $seller ? ($seller->getFirstName() . ' ' . $seller->getLastName()) : 'N/A',
                'ownerEmail'     => $seller?->getEmail() ?? '',
                'sellerName'     => $seller ? ($seller->getFirstName() . ' ' . $seller->getLastName()) : 'N/A',
                'commissionRate' => $rate,
                'isActive'       => $store->isActive(),
            ];
        }, $stores);

        return $this->json(['stores' => $result]);
    }

    /**
     * PUT /api/admin/stores/{id}/commission
     * Update commission rate for a single store.
     */
    #[Route('/stores/{id}/commission', name: 'update_store', methods: ['PUT'])]
    public function updateStoreCommission(string $id, Request $request): JsonResponse
    {
        $this->denyAccessUnlessGranted('ROLE_ADMIN');

        $store = $this->foodStoreRepository->find($id);
        if (!$store) {
            return $this->json(['error' => 'Store not found.'], 404);
        }

        $data = json_decode($request->getContent(), true);

        if (!isset($data['commissionRate'])) {
            return $this->json(['error' => 'commissionRate is required.'], 400);
        }

        $rate = (float) $data['commissionRate'];
        if ($rate < 0 || $rate > 50) {
            return $this->json(['error' => 'commissionRate must be between 0 and 50.'], 400);
        }

        $store->setCommissionRate($rate);
        $store->setCommissionOverride($rate !== self::DEFAULT_RATE);

        $this->entityManager->flush();

        return $this->json([
            'storeId'        => $store->getId(),
            'commissionRate' => $store->getCommissionRate(),
            'message'        => 'Commission updated.',
        ]);
    }
}
