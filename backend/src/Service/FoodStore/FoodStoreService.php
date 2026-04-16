<?php

namespace App\Service\FoodStore;

use App\Entity\Enum\StoreType;
use App\Entity\FoodStore;
use App\Entity\Location;
use App\Entity\User;
use App\Exception\ValidationException;
use App\Helper\PaginationHelper;
use App\Helper\SearchHelper;
use App\Helper\SortingHelper;
use App\Helper\ValidationHelper;
use App\Repository\FoodStoreRepository;
use App\Repository\LocationRepository;
use App\Service\Location\LocationMapper;
use App\Service\Location\LocationService;
use Doctrine\ORM\EntityManagerInterface;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;

class FoodStoreService {
    public function __construct(
        private FoodStoreRepository $foodStoreRepository,
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private ValidationHelper $validationHelper,
        private FoodStoreMapper $foodStoreMapper,
        private LocationService $locationService,
        private LocationMapper $locationMapper
    ) {}

    public function addFoodStoreLocation(string $foodStoreId, array $locationData): JsonResponse
    {
        $foodStore = $this->foodStoreRepository->find($foodStoreId);

        if (!$foodStore instanceof FoodStore) {
            return new JsonResponse(['error' => 'Food store not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        try {
            $this->locationService->createLocation($foodStore, null, $locationData);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }

        // $locationDTO = $this->locationMapper->mapToDTO($location);
        // return new JsonResponse($locationDTO);
        //location is part of FoodStore DTO so we return the whole FoodStore DTO instead of the location
        $foodStoreDTO = $this->foodStoreMapper->mapToDTO($foodStore);
        return new JsonResponse($foodStoreDTO);
    }

    public function updateFoodStoreLocation(string $foodStoreId, array $data): JsonResponse
    {
        $foodStore = $this->foodStoreRepository->find($foodStoreId);

        if (!$foodStore instanceof FoodStore) {
            return new JsonResponse(['error' => 'Food store not found'], JsonResponse::HTTP_NOT_FOUND);
        }
    
        try {
            $this->locationService->upsertFoodStoreLocation($foodStore, $data);
            //location is part of FoodStore DTO so we return the whole FoodStore DTO instead of the location
            $foodStoreDTO = $this->foodStoreMapper->mapToDTO($foodStore);
            return new JsonResponse($foodStoreDTO);

        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        
        } catch (NotFoundHttpException $e) {
            return new JsonResponse(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    public function getAllFoodStores(
        int $page,
        int $limit,
        string $sortBy,
        string $sortOrder,
        ?string $search = null,
        array $locationFilters = [],
        ?string $type = null,
        bool $onlyActive = true
    ): array {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);
    
        [$sortBy, $sortOrder] = SortingHelper::validateSorting($sortBy, $sortOrder, FoodStore::ALLOWED_SORT_FIELDS);
    
        $search = SearchHelper::validate($search);

        foreach ($locationFilters as $key => $value) {
            $locationFilters[$key] = SearchHelper::normalizeStringFilter($value);
        }

        if ($type !== null) {
            $type = strtolower($type);
            if (!in_array($type, array_map(fn(StoreType $t) => $t->value, StoreType::cases()), true)) {
                throw new InvalidArgumentException('Invalid store type');
            }
        }
    
        $foodStores = $this->foodStoreRepository->findAllWithSearch($search, $sortBy, $sortOrder, $limit, $offset, $locationFilters, $type, $onlyActive);
        $totalFoodStores = $this->foodStoreRepository->countWithSearch($search, $locationFilters, $type, $onlyActive);
    
        $foodStoresDTO = $this->foodStoreMapper->mapToDTOs($foodStores);
    
        return PaginationHelper::createPaginatedResponse($page, $limit, $totalFoodStores, $foodStoresDTO);
    }

    public function getNearbyFoodStores(int $limit, $latitude, $longitude, $radiusKm, bool $onlyActive = true): array
    {
        if (!is_numeric($latitude) || !is_numeric($longitude) || !is_numeric($radiusKm)) {
            throw new \InvalidArgumentException('Latitude, longitude, and radius must be valid numbers.');
        }
    
        $latitude = (float) $latitude;
        $longitude = (float) $longitude;
        $radiusKm = (float) $radiusKm;
    
        if ($latitude < -90 || $latitude > 90) {
            throw new \InvalidArgumentException('Latitude must be between -90 and 90.');
        }
    
        if ($longitude < -180 || $longitude > 180) {
            throw new \InvalidArgumentException('Longitude must be between -180 and 180.');
        }
    
        if ($radiusKm < 0.1 || $radiusKm > 100) {
            throw new \InvalidArgumentException('Radius must be between 0.1 and 100 kilometers');
        }

        [$page, $limit] = PaginationHelper::calculate(1, $limit);
    
        $foodStores = $this->foodStoreRepository->findNearbyStores($latitude, $longitude, $radiusKm, $limit, $onlyActive);
    
        $foodStoresDTO = $this->foodStoreMapper->mapToDTOs($foodStores);

        return $foodStoresDTO;
    }

}