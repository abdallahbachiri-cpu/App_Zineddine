<?php

namespace App\Service\Location;

use App\Entity\FoodStore;
use App\Entity\Location;
use App\Entity\User;
use App\Exception\ValidationException;
use App\Helper\ValidationHelper;
use App\Repository\LocationRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Constraints\Collection;

class LocationService
{
    public function __construct(
        private LocationRepository $locationRepository,
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private ValidationHelper $validationHelper,
        private LocationMapper $locationMapper
    ) {}

    public static function getConstraints(bool $isUpdate = false, bool $isFoodStore = false): Collection
    {
        $cityConstraints = [new Assert\Type('string'), new Assert\Length(['max' => 50])];
        $stateConstraints = [new Assert\Type('string'), new Assert\Length(['max' => 50])];
        $zipCodeConstraints = [new Assert\Type('string'), new Assert\Length(['max' => 15])];
        $countryConstraints = [new Assert\Type('string'), new Assert\Length(['max' => 100])];

        if ($isFoodStore) {
            $cityConstraints[] = new Assert\NotBlank();
            $stateConstraints[] = new Assert\NotBlank();
            // Zip code no longer required for food store
            $zipCodeConstraints = new Assert\Optional($zipCodeConstraints);
            $countryConstraints[] = new Assert\NotBlank();
        } else {
            $cityConstraints = new Assert\Optional($cityConstraints);
            $stateConstraints = new Assert\Optional($stateConstraints);
            $zipCodeConstraints = new Assert\Optional($zipCodeConstraints);
            $countryConstraints = new Assert\Optional($countryConstraints);
        }

        return new Collection([
            'fields' => [
                'latitude' => [new Assert\NotBlank(), new Assert\Type('float')],
                'longitude' => [new Assert\NotBlank(), new Assert\Type('float')],
                'street' => new Assert\Optional([new Assert\Type('string'), new Assert\Length(['max' => 255])]),
                'city' => $cityConstraints,
                'state' => $stateConstraints,
                'zipCode' => $zipCodeConstraints,
                'country' => $countryConstraints,
                'additionalDetails' => new Assert\Optional([new Assert\Type('string'), new Assert\Length(['max' => 255])]),
            ],
            'allowMissingFields' => $isUpdate,
        ]);
    }

    public function normalizeLocationData(array $locationData): array
    {
        if (isset($locationData['latitude']) && is_numeric($locationData['latitude'])) {
            $locationData['latitude'] = (float) $locationData['latitude'];
        }
        if (isset($locationData['longitude']) && is_numeric($locationData['longitude'])) {
            $locationData['longitude'] = (float) $locationData['longitude'];
        }
    
        return $locationData;
    }

    public function createLocation(?FoodStore $foodStore, ?User $user, array $data): Location
    {
        $this->validateLocationCreationData($data);
        
        $location = new Location();
        $location->setLatitude($data['latitude']);
        $location->setLongitude($data['longitude']);
        $location->setStreet($data['street'] ?? null);
        $location->setCity($data['city'] ?? null);
        $location->setState($data['state'] ?? null);
        $location->setZipCode($data['zipCode'] ?? null);
        $location->setCountry($data['country'] ?? null);
        $location->setAdditionalDetails($data['additionalDetails'] ?? null);

        if ($foodStore instanceof FoodStore) {
            $seller = $foodStore->getSeller();
            $location->setFoodStore($foodStore);
            $location->setUser($seller);

        } elseif ($user instanceof User) {
            $location->setUser($user);

        } else {
            throw new \InvalidArgumentException("A location must be assigned to either a user or a food store.");
        }

        $this->entityManager->persist($location);
        $this->entityManager->flush();

        return $location;
    }

    public function updateUserLocation(User $user, string $locationId, array $data): Location
    {
        $location = $this->locationRepository->find($locationId);
    
        if (!$location instanceof Location || $location->getUser() !== $user) {
            throw new NotFoundHttpException('Location not found');
        }
    
        $this->validateLocationUpdateData($data);
        $this->applyLocationUpdates($location, $data);
    
        $this->entityManager->flush();
    
        return $location;
    }

    public function upsertFoodStoreLocation(FoodStore $foodStore, array $data): Location
    {
        $location = $foodStore->getLocation();
        if (!$location instanceof Location) {
            return $this->createLocation($foodStore, null, $data);
        }
        //commented because we have one address per store for now
        // $location = $this->locationRepository->find($locationId);
        // if (!$location instanceof Location || $location->getFoodStore() !== $foodStore) {
        //     throw new NotFoundHttpException('Location not found');
        // }
    
        $this->validateLocationUpdateData($data);
        $this->applyLocationUpdates($location, $data);
    
        $this->entityManager->flush();
    
        return $location;
    }
    

    public function removeLocation(Location $location): void
    {
        $this->entityManager->remove($location);
        $this->entityManager->flush();
    }

    public function getLocationById(string $locationId): ?Location
    {
        return $this->locationRepository->find($locationId);
    }

    public function getUserLocations(User $user): array
    {
        return $this->locationRepository->findBy(['user' => $user]);
    }

    private function validateLocationCreationData(array $data, bool $isFoodStore = false): void
    {
        $constraints = $this::getConstraints(false, $isFoodStore);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            throw new ValidationException($errors);
        }
    }

    private function validateLocationUpdateData(array $data, bool $isFoodStore = false): void
    {
        $constraints = $this::getConstraints(true, $isFoodStore);

        $errors = $this->validator->validate($data, $constraints);
        if (count($errors) > 0) {
            throw new ValidationException($errors);
        }
    }

    private function applyLocationUpdates(Location $location, array $data): void
    {
        $updatableFields = [
            'latitude' => 'setLatitude',
            'longitude' => 'setLongitude',
            'street' => 'setStreet',
            'city' => 'setCity',
            'state' => 'setState',
            'zipCode' => 'setZipCode',
            'country' => 'setCountry',
            'additionalDetails' => 'setAdditionalDetails',
        ];

        foreach ($updatableFields as $field => $setter) {
            if (array_key_exists($field, $data)) {
                $location->$setter($data[$field]);
            }
        }
    }
}
