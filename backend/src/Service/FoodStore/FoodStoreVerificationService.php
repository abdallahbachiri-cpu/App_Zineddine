<?php
namespace App\Service\FoodStore;

use App\Entity\FoodStore;
use App\Entity\FoodStoreVerificationRequest;
use App\Entity\Media;
use App\Entity\Enum\StoreVerificationStatus;
use App\Entity\User;
use App\Helper\PaginationHelper;
use App\Helper\SortingHelper;
use App\Helper\ValidationHelper;
use App\Repository\FoodStoreVerificationRequestRepository;
use App\Service\Media\MediaService;
use Doctrine\ORM\EntityManagerInterface;
use InvalidArgumentException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class FoodStoreVerificationService
{
    private FoodStoreVerificationRequestRepository $verificationRequestRepository;
    private EntityManagerInterface $entityManager;

    public function __construct(
        FoodStoreVerificationRequestRepository $verificationRequestRepository,
        EntityManagerInterface $entityManager,
        private MediaService $mediaService,
        private FoodStoreVerificationRequestMapper $mapper
    )
    {
        $this->verificationRequestRepository = $verificationRequestRepository;
        $this->entityManager = $entityManager;
    }

    public function getAllVerificationRequests(
        int $page,
        int $limit,
        string $sortBy,
        string $sortOrder,
        array $filters = []
    ): array {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);
        
        [$sortBy, $sortOrder] = SortingHelper::validateSorting(
            $sortBy,
            $sortOrder,
            FoodStoreVerificationRequest::ALLOWED_SORT_FIELDS
        );

        // Apply filters
        $criteria = [];
        foreach ($filters as $field => $value) {
            if (in_array($field, FoodStoreVerificationRequest::FILTERABLE_FIELDS, true)) {
                $criteria[$field] = $value;
            }
        }

        $requests = $this->verificationRequestRepository->findAllWithFilters(
            $criteria,
            $sortBy,
            $sortOrder,
            $limit,
            $offset
        );

        $total = $this->verificationRequestRepository->countWithFilters($criteria);

        return PaginationHelper::createPaginatedResponse(
            $page,
            $limit,
            $total,
            $this->mapper->mapToDTOs($requests)
        );
    }

    public function getVerificationRequestsByFoodStore(
        FoodStore $foodStore,
        int $page,
        int $limit,
        string $sortBy,
        string $sortOrder
    ): array {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);
        
        [$sortBy, $sortOrder] = SortingHelper::validateSorting(
            $sortBy,
            $sortOrder,
            FoodStoreVerificationRequest::ALLOWED_SORT_FIELDS
        );

        $requests = $this->verificationRequestRepository->findBy(
            ['foodStore' => $foodStore],
            [$sortBy => $sortOrder],
            $limit,
            $offset
        );

        $total = $this->verificationRequestRepository->count(['foodStore' => $foodStore]);

        return PaginationHelper::createPaginatedResponse(
            $page,
            $limit,
            $total,
            $this->mapper->mapToDTOs($requests)
        );
    }

    public function createVerificationRequest(FoodStore $foodStore, array $uploadedFiles): FoodStoreVerificationRequest
    {
        $existingRequest = $this->verificationRequestRepository
            ->findOneBy([
                'foodStore' => $foodStore,
                'status' => StoreVerificationStatus::Pending
        ]);

        if ($existingRequest) {
            throw new ConflictHttpException('There is already a pending verification request for this food store.');
        }

        // Create a new verification request
        $verificationRequest = new FoodStoreVerificationRequest($foodStore);
        $verificationRequest->setStatus(StoreVerificationStatus::Pending);
        foreach ($uploadedFiles as $uploadedFile) {
            $media = $this->mediaService->uploadSecure($uploadedFile);
            $verificationRequest->addDocument($media);
        }
        // $verificationRequest->setAdminComment(null);

        $this->entityManager->persist($verificationRequest);
        $this->entityManager->flush();

        return $verificationRequest;
    }

    public function approveRequest(
        string $requestId,
        User $admin,
        ?string $note = null
    ): FoodStoreVerificationRequest {
        if (!ValidationHelper::isCorrectUuid($requestId)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $verificationRequest = $this->verificationRequestRepository->find($requestId);
        if (!$verificationRequest) {
            throw new NotFoundHttpException('Verification request not found');
        }
    
        if ($verificationRequest->getStatus() !== StoreVerificationStatus::Pending) {
            throw new \InvalidArgumentException('Only pending requests can be approved');
        }
    
        $verificationRequest->setStatus(StoreVerificationStatus::Approved);
        $verificationRequest->setVerifiedBy($admin);
        $verificationRequest->setAdminComment($note);
    
        // Activate the food store upon approval
        $foodStore = $verificationRequest->getFoodStore();
        $foodStore->setActive(true);
    
        $this->entityManager->flush();
    
        return $verificationRequest;
    }
    
    public function rejectRequest(
        string $requestId,
        User $admin,
        string $note
    ): FoodStoreVerificationRequest {
        if (!ValidationHelper::isCorrectUuid($requestId)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $verificationRequest = $this->verificationRequestRepository->find($requestId);
        if (!$verificationRequest) {
            throw new NotFoundHttpException('Verification request not found');
        }
    
        if ($verificationRequest->getStatus() !== StoreVerificationStatus::Pending) {
            throw new \InvalidArgumentException('Only pending requests can be rejected');
        }
    
        $verificationRequest->setStatus(StoreVerificationStatus::Rejected);
        $verificationRequest->setVerifiedBy($admin);
        $verificationRequest->setAdminComment($note);
    
        $this->entityManager->flush();
    
        return $verificationRequest;
    }

    /**
     * Delete a verification request.
     */
    public function deleteVerificationRequest(FoodStoreVerificationRequest $verificationRequest): void
    {
        $this->entityManager->remove($verificationRequest);
        $this->entityManager->flush();
    }

    public function deletePendingRequest(string $requestId, FoodStore $foodStore): void
    {
        if (!ValidationHelper::isCorrectUuid($requestId)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        $verificationRequest = $this->verificationRequestRepository->findOneBy(['id' => $requestId, 'foodStore' => $foodStore]);
        if (!$verificationRequest instanceof FoodStoreVerificationRequest) {
            throw new NotFoundHttpException('Verification request not found');
        }

        if ($verificationRequest->getStatus() !== StoreVerificationStatus::Pending) {
            throw new ConflictHttpException('Only pending verification requests can be deleted');
        }

        $mediaToDelete = [];
        foreach ($verificationRequest->getDocuments() as $media) {
            $mediaToDelete[] = $media;
        }

        // Delete the request
        $this->entityManager->remove($verificationRequest);
        $this->entityManager->flush();

        // Delete associated media files and entities
        foreach ($mediaToDelete as $media) {
            if (!$media instanceof Media) {
                continue;
            }
            try {
                $this->mediaService->delete($media);
            } catch (\Exception $e) {
                // throw new \RuntimeException('Failed to delete media: ' . $e->getMessage());
            }
        }
        
        $this->entityManager->flush();
    }

    public function findMediaDocumentInVerificationRequest(FoodStoreVerificationRequest $request, string $mediaId): Media
    {
        foreach ($request->getDocuments() as $media) {
            if ($media instanceof Media && $media->getId() === $mediaId) {
                return $media;
            }
        }
        throw new NotFoundHttpException('Document not found in this verification request');
    }
}
