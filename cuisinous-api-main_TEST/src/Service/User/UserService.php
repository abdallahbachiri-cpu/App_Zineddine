<?php

namespace App\Service\User;

use App\Entity\Location;
use App\Entity\User;
use App\Exception\ValidationException;
use App\Helper\PaginationHelper;
use App\Helper\SearchHelper;
use App\Helper\SortingHelper;
use App\Helper\ValidationHelper;
use App\Repository\UserRepository;
use App\Service\Email\EmailTemplateRenderer;
use App\Service\Location\LocationMapper;
use App\Service\Location\LocationService;
use App\Service\Mailer\MailService;
use Doctrine\ORM\EntityManagerInterface;
use DomainException;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Contracts\Translation\TranslatorInterface;

class UserService
{
    public function __construct(
        private UserRepository $userRepository,
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private ValidationHelper $validationHelper,
        private UserMapper $userMapper,
        private LocationService $locationService,
        private LocationMapper $locationMapper,
        private MailService $mailService,
        private EmailTemplateRenderer $emailTemplateRenderer,
        private TranslatorInterface $translator,
        private UserPasswordHasherInterface $passwordHasher,
    ) {}


    public function getAllUsers(int $page, int $limit, string $sortBy, string $sortOrder, ?string $search = null, ?string $userType = null): array
    {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);

        [$sortBy, $sortOrder] = SortingHelper::validateSorting($sortBy, $sortOrder, User::ALLOWED_SORT_FIELDS);

        $search = SearchHelper::validate($search);

        if ($userType !== null) {
            $this->validateUserType($userType);
        }

        $users = $this->userRepository->findAllWithSearch($search, $sortBy, $sortOrder, $limit, $offset, $userType);
        $totalUsers = $this->userRepository->countWithSearch($search, $userType);

        $usersDTO = $this->userMapper->mapToDTOs($users);

        return PaginationHelper::createPaginatedResponse($page, $limit, $totalUsers, $usersDTO);
    }

    public function getUserById(string $id)
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $user = $this->userRepository->find($id);

        if (!$user instanceof User) {
            return null;
        }

        return $this->userMapper->mapToDTO($user);
    }

    public function updateUser(string $id, array $data): JsonResponse
    {

        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        $user = $this->userRepository->find($id);

        if (!$user instanceof User) {
            throw new NotFoundHttpException('User not found');
        }

        if (array_key_exists('locale', $data) &&  is_string($data['locale'])) {
            $data['locale'] = strtolower($data['locale']);
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'phoneNumber' => [new Assert\Optional(), new Assert\Regex('/^\\+?[0-9]+$/')],
                // 'email' => [
                //     new Assert\Optional(),
                //     new Assert\Type('string'),
                //     new Assert\Email(),
                //     new Assert\Length(['max' => 255])
                // ],
                'firstName' => [new Assert\Optional(), new Assert\Type('string'), new Assert\Length(['max' => 50])],
                'lastName' => [new Assert\Optional(), new Assert\Type('string'), new Assert\Length(['max' => 50])],
                'middleName' => [new Assert\Optional(), new Assert\Type('string'), new Assert\Length(['max' => 255])],
                'type' => [new Assert\Optional(), new Assert\Choice(['choices' => User::getAllowedTypes()])],
                'locale' => [new Assert\Optional(), new Assert\Choice(['choices' => ['en', 'fr']])],
            ],
            'allowMissingFields' => true,
        ]);

        // Validate the data
        $errors = $this->validator->validate($data, $constraints);
        if (count($errors) > 0) {
            throw new ValidationException($errors);
        }

        // Update fields
        $fields = [
            // 'email' => 'setEmail',
            'firstName' => 'setFirstName',
            'lastName' => 'setLastName',
            'middleName' => 'setMiddleName',
            'phoneNumber' => 'setPhoneNumber',
            'locale' => 'setLocale',
        ];

        if (isset($data['type'])) {
            if ($user->getType() === null) {
                $user->setType($data['type']);
            } else {
                throw new DomainException('Account type cannot be changed after assignment');
            }
        }

        foreach ($fields as $field => $setter) {
            if (isset($data[$field])) {
                $user->$setter($data[$field]);
            }
        }

        if (array_key_exists('middleName', $data)) {
            $user->setMiddleName(
                $data['middleName'] === '' || $data['middleName'] === null
                    ? null
                    : $data['middleName']
            );
        }

        // Auto-complete Google onboarding if needed
        if ($user->getGoogleId() !== null && $user->isGoogleOnboardingCompleted() !== true) {
            $requiredFields = ['firstName', 'lastName', 'phoneNumber'];

            $hasRequiredFieldInRequest = count(array_intersect(array_keys($data), $requiredFields)) > 0;

            // If at least one required field is in the request AND all required fields are now populated
            if ($hasRequiredFieldInRequest) {
                $hasAllRequiredFields = !empty($user->getFirstName())
                    && !empty($user->getLastName())
                    && !empty($user->getPhoneNumber());

                if ($hasAllRequiredFields) {
                    $user->setIsGoogleOnboardingCompleted(true);
                }
            }
        }

        $this->entityManager->flush();

        $userDTO = $this->userMapper->mapToDTO($user);

        return new JsonResponse($userDTO);
    }

    public function softDeleteUser(string $id): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        $user = $this->userRepository->find($id);

        if (!$user instanceof User) {
            throw new NotFoundHttpException('User not found');
        }

        $user->softDelete();
        $this->entityManager->flush();

        return new JsonResponse(['message' => 'User has been deleted (soft delete applied).']);
    }

    public function getAvailableUsers(int $page, int $limit): array
    {
        [$page, $limit, $offset] = PaginationHelper::calculate($page, $limit);

        $users = $this->userRepository->findAvailableUsers($limit, $offset);
        $totalUsers = $this->userRepository->countAvailableUsers();

        $usersDTO = $this->userMapper->mapToDTOs($users);

        return PaginationHelper::createPaginatedResponse($page, $limit, $totalUsers, $usersDTO);
    }

    public function restoreUser(string $id): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $user = $this->userRepository->find($id);

        if (!$user instanceof User) {
            throw new NotFoundHttpException('User not found');
        }

        if ($user->getDeletedAt() === null) {
            throw new ConflictHttpException('User is not deleted');
        }

        $user->restore();
        $this->entityManager->flush();

        return new JsonResponse([['message' => 'User has been restored'], Response::HTTP_OK]);
    }

    public function activateUser(string $id): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $user = $this->userRepository->find($id);

        if (!$user instanceof User) {
            throw new NotFoundHttpException('User not found');
        }

        if ($user->isActive()) {
            throw new ConflictHttpException('User is already active');
        }

        $user->activate();
        $this->entityManager->flush();

        return new JsonResponse([['message' => 'User has been activated'], Response::HTTP_OK]);
    }

    public function suspendUser(string $id): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($id)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }

        $user = $this->userRepository->find($id);

        if (!$user instanceof User) {
            throw new NotFoundHttpException('User not found');
        }

        if (!$user->isActive()) {
            throw new ConflictHttpException('User is already suspended');
        }

        $user->suspend();
        $this->entityManager->flush();

        return new JsonResponse([['message' => 'User has been suspended'], Response::HTTP_OK]);
    }

    public function addUserLocation(string $userId, array $locationData): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($userId)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }
        $user = $this->userRepository->find($userId);

        if (!$user instanceof User) {
            return new JsonResponse(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        try {
            $location = $this->locationService->createLocation(null, $user, $locationData);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }

        $locationDTO = $this->locationMapper->mapToDTO($location);
        return new JsonResponse($locationDTO);
    }

    // @TODO refactor getLocationById functions
    public function getUserLocationEntityById(string $userId, string $locationId): Location
    {
        if (!ValidationHelper::isCorrectUuid($userId)) {
            throw new InvalidArgumentException('Invalid UUID format');
        }
        $user = $this->userRepository->find($userId);

        if (!$user instanceof User) {
            throw new NotFoundHttpException('User not found');
        }

        $location = $this->locationService->getLocationById($locationId);

        if (!$location instanceof Location || $location->getUser() !== $user) {
            throw new NotFoundHttpException('Location not found');
        }
        return $location;
    }

    public function getUserLocationById(string $userId, string $locationId): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($userId)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }
        $user = $this->userRepository->find($userId);

        if (!$user instanceof User) {
            return new JsonResponse(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $location = $this->locationService->getLocationById($locationId);

        if (!$location instanceof Location || $location->getUser() !== $user) {
            return new JsonResponse(['error' => 'Location not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $locationDTO = $this->locationMapper->mapToDTO($location);

        return new JsonResponse($locationDTO);
    }

    public function updateUserLocation(string $userId, string $locationId, array $data): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($userId)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $user = $this->userRepository->find($userId);

        if (!$user instanceof User) {
            return new JsonResponse(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        try {
            $location = $this->locationService->updateUserLocation($user, $locationId, $data);

            if (isset($data['default']) && $data['default'] === true) {
                if ($user->getDefaultAddress() !== $location) {
                    $user->setDefaultAddress($location);
                    $this->entityManager->flush();
                }
            }

            $locationDTO = $this->locationMapper->mapToDTO($location);
            return new JsonResponse($locationDTO);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return new JsonResponse(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        }
    }

    public function removeUserLocation(string $userId, string $locationId): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($userId)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $user = $this->userRepository->find($userId);

        if (!$user instanceof User) {
            return new JsonResponse(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $location = $this->locationService->getLocationById($locationId);

        if (!$location instanceof Location || $location->getUser() !== $user) {
            return new JsonResponse(['error' => 'Location not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        // Prevent deletion of default address
        if ($user->getDefaultAddress() === $location) {
            return new JsonResponse(['error' => 'Cannot delete the default address'], JsonResponse::HTTP_BAD_REQUEST);
        }

        try {
            $this->locationService->removeLocation($location);
            return new JsonResponse(['message' => 'Location removed successfully']);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Something went wrong'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function getUserLocations(string $userId): JsonResponse
    {
        if (!ValidationHelper::isCorrectUuid($userId)) {
            // @todo throw errors instead of direct response return
            //throw new InvalidArgumentException('Invalid UUID format');
            return new JsonResponse(['error' => 'Invalid UUID format.'], JsonResponse::HTTP_BAD_REQUEST);
        }
        $user = $this->userRepository->find($userId);

        if (!$user instanceof User) {
            return new JsonResponse(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        $locations = $this->locationService->getUserLocations($user);
        $locationDTOs = $this->locationMapper->mapToDTOs($locations);

        return new JsonResponse($locationDTOs);
    }

    private function validateUserType(string $type): void
    {
        $allowedTypes = User::getAllowedTypes();

        if (!in_array($type, $allowedTypes, true)) {
            $errorMessage = sprintf(
                "Invalid user type: %s. Allowed types are: %s.",
                $type,
                implode(", ", array_map(fn($t) => "'$t'", $allowedTypes))
            );
            throw new \InvalidArgumentException($errorMessage);
        }
    }

    public function sendConfirmationEmail(User $user, string $locale = 'en'): void
    {
        $token = $user->generateEmailConfirmationToken();
        $this->entityManager->flush();

        $emailContent = $this->emailTemplateRenderer->renderEmailConfirmationEmail(
            $locale,
            $user,
            $token
        );

        $subject = $this->translator->trans(
            'email_confirmation.subject',
            [],
            'messages',
            $locale
        );

        $this->mailService->send(
            $user->getEmail(),
            $subject,
            $emailContent['html'],
            $emailContent['text']
        );
    }

    public function createAdminUser(array $data): JsonResponse
    {
        $constraints = new Assert\Collection([
            'fields' => [
                'email' => [
                    new Assert\NotBlank(),
                    new Assert\Email(),
                    new Assert\Length(['max' => 255])
                ],
                'password' => [
                    new Assert\NotBlank(),
                    new Assert\Length(['min' => 8]),
                    new Assert\Regex('/[A-Z]/', message: 'Password must contain at least one uppercase letter.'),
                    new Assert\Regex('/[a-z]/', message: 'Password must contain at least one lowercase letter.'),
                    new Assert\Regex('/[0-9]/', message: 'Password must contain at least one number.'),
                    new Assert\Regex('/[\W]/', message: 'Password must contain at least one special character.')
                ],
                'firstName' => [
                    new Assert\NotBlank(),
                    new Assert\Length(['max' => 50])
                ],
                'lastName' => [
                    new Assert\NotBlank(),
                    new Assert\Length(['max' => 50])
                ],
                'locale' => new Assert\Optional([
                    new Assert\Choice(['choices' => ['en', 'fr']])
                ])
            ],
            'allowExtraFields' => true
        ]);

        $errors = $this->validator->validate($data, $constraints);
        if (count($errors) > 0) {
            return new JsonResponse(
                ['errors' => ValidationHelper::formatErrors($errors)],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $email = $data['email'];
        $existingUser = $this->userRepository->findUserByEmail($email);

        if ($existingUser instanceof User) {
            return new JsonResponse(
                ['errors' => ['An account with this email already exists.']],
                Response::HTTP_CONFLICT
            );
        }

        $normalizedEmail = $this->validationHelper->normalizeEmail($data['email']);
        $admin = new User();
        $admin->setFirstName(trim($data['firstName']) ?? 'Admin');
        $admin->setLastName(trim($data['lastName']) ?? 'User');
        $admin->setEmail($normalizedEmail);
        $admin->setType(User::TYPE_ADMIN);
        $admin->setPassword($this->passwordHasher->hashPassword($admin, $data['password']));
        $admin->setEmailConfirmed(true);
        $admin->setActive(true);
        $admin->setLocale($data['locale'] ?? 'en');

        $this->entityManager->persist($admin);
        $this->entityManager->flush();

        return new JsonResponse($this->userMapper->mapToDTO($admin));
    }
}
