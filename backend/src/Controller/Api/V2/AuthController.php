<?php

namespace App\Controller\Api\V2;

use App\Controller\Abstract\BaseController;
use App\DTO\UserDTO;
use App\Entity\User;
use App\Service\User\Auth\AuthService;
use App\Service\GoogleOAuthService;
use App\Service\AppleOAuthService;
use App\Helper\ValidationHelper;
use App\Repository\UserRepository;
use App\Service\User\UserMapper;
use App\Exception\ValidationException;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;

#[Route('/api/v2/auth', name: 'v2_auth_')]
class AuthController extends BaseController
{
    public function __construct(
        private AuthService $authService,
        private GoogleOAuthService $googleOAuthService,
        private AppleOAuthService $appleOAuthService,
        private EntityManagerInterface $entityManager,
        private UserRepository $userRepository,
        private ValidatorInterface $validator,
        private ValidationHelper $validationHelper,
        private UserMapper $userMapper
    ) {
    }

    #[Route('/login', name: 'login', methods: ['POST'])]
    #[OA\Post(
        summary: "Authenticate a user (v2)",
        description: "Authenticates a user and updates their FCM token for push notifications.",
        tags: ["Authentication v2"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "email", type: "string", format: "email", example: "user@example.com"),
                    new OA\Property(property: "password", type: "string", example: "securePassword123!"),
                    new OA\Property(property: "googleToken", type: "string", nullable: true),
                    new OA\Property(property: "fcm_token", type: "string", nullable: true, description: "Firebase Cloud Messaging token"),
                    new OA\Property(property: "rememberMe", type: "boolean", default: false)
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: "Login successful"),
            new OA\Response(response: 401, description: "Invalid credentials")
        ]
    )]
    public function login(Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);
        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], Response::HTTP_BAD_REQUEST);
        }

        $fcmToken = $data['fcm_token'] ?? null;
        $password = null;
        $isGoogleAuth = false;
        $isAppleAuth = false;

        if (isset($data['appleToken']) && is_string($data['appleToken'])) {
            try {
                $appleUserData = $this->appleOAuthService->validateAppleToken($data['appleToken'], $data);
            } catch (\Exception $e) {
                return $this->json(['error' => 'Apple authentication failed.'], Response::HTTP_BAD_REQUEST);
            }
            $user = $this->userRepository->findOneBy(['appleId' => $appleUserData['appleId']]);
            if (!$user) {
                $user = $this->userRepository->findUserByEmail($appleUserData['email']);
                if ($user instanceof User) {
                    $user->setAppleId($appleUserData['appleId']);
                    $this->entityManager->flush();
                }
            }
            $isAppleAuth = true;
        } elseif (isset($data['googleToken'])) {
            try {
                $googleUserInfo = $this->googleOAuthService->fetchUserInfo($data['googleToken']);
                $email = (string) $googleUserInfo->email;
                $user = $this->userRepository->findUserByEmail($email);
            } catch (\Exception $e) {
                return $this->json(['error' => 'Google authentication failed.'], Response::HTTP_BAD_REQUEST);
            }
            $isGoogleAuth = true;
        } else {
            $email = $data['email'] ?? null;
            $password = $data['password'] ?? null;

            if (!$email || !$password) {
                return $this->json(['error' => 'Email and password are required.'], Response::HTTP_BAD_REQUEST);
            }

            $user = $this->userRepository->findUserByEmail($email);
        }

        $isOAuth = $isGoogleAuth || $isAppleAuth;

        if (!$user instanceof User || (!$isOAuth && !$this->authService->isPasswordValid($user, $password))) {
            return $this->json(['error' => 'Invalid credentials.'], Response::HTTP_UNAUTHORIZED);
        }

        if (!$user->isAvailable()) {
            return $this->json(['error' => 'Account is inactive or deleted.'], Response::HTTP_FORBIDDEN);
        }

        // Update FCM Token
        if ($fcmToken) {
            $this->authService->captureFcmToken($user, $fcmToken);
        }

        $rememberMe = (bool)($data['rememberMe'] ?? false);
        $result = $this->authService->generateTokens($user, $rememberMe);
        $result['isGoogleAuth'] = $isGoogleAuth;
        $result['isAppleAuth'] = $isAppleAuth;
        $result['user'] = $this->userMapper->mapToDTO($user);

        return $this->json($result);
    }

    #[Route('/register', name: 'register', methods: ['POST'])]
    #[OA\Post(
        summary: "Register a new user (v2)",
        description: "Creates a new user account and registers their initial FCM token.",
        tags: ["Authentication v2"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "email", type: "string", format: "email"),
                    new OA\Property(property: "password", type: "string"),
                    new OA\Property(property: "firstName", type: "string"),
                    new OA\Property(property: "lastName", type: "string"),
                    new OA\Property(property: "fcm_token", type: "string", nullable: true),
                    new OA\Property(property: "googleToken", type: "string", nullable: true),
                    new OA\Property(property: "locale", type: "string", enum: ["en", "fr"], default: "en")
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: "User registered successfully"),
            new OA\Response(response: 409, description: "Conflict - Email exists")
        ]
    )]
    public function register(Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);
        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], Response::HTTP_BAD_REQUEST);
        }

        $fcmToken = $data['fcm_token'] ?? null;

        try {
            $isGoogleAuth = false;
            $isAppleAuth = false;

            if (isset($data['appleToken']) && is_string($data['appleToken'])) {
                try {
                    $appleData = $this->appleOAuthService->validateAppleToken($data['appleToken'], $data);
                } catch (\Exception $e) {
                    return $this->json(['errors' => ['Apple authentication failed: ' . $e->getMessage()]], Response::HTTP_BAD_REQUEST);
                }

                $existingUser = $this->userRepository->findOneBy(['appleId' => $appleData['appleId']]);
                if ($existingUser) {
                    return $this->json(['errors' => ['An account associated with this Apple ID already exists.']], Response::HTTP_CONFLICT);
                }

                $existingByEmail = $this->userRepository->findUserByEmail($appleData['email']);
                if ($existingByEmail) {
                    $existingByEmail->setAppleId($appleData['appleId']);
                    if ($fcmToken) {
                        $existingByEmail->setFcmToken($fcmToken);
                    }
                    $this->entityManager->flush();
                    $user = $existingByEmail;
                } else {
                    $appleData['locale'] = $data['locale'] ?? 'en';
                    $user = $this->authService->createUserFromAppleData($appleData, $fcmToken);
                }
                $isAppleAuth = true;
            } elseif (isset($data['googleToken'])) {
                $googleData = $this->googleOAuthService->validateGoogleToken($data['googleToken']);
                $googleData['locale'] = $data['locale'] ?? 'en';

                $existingUser = $this->userRepository->findOneBy(['googleId' => $googleData['googleId']]);
                if ($existingUser) {
                    return $this->json(['errors' => ['An account associated with this Google account already exists.']], Response::HTTP_CONFLICT);
                }

                $user = $this->authService->createUserFromGoogleData($googleData, $fcmToken);
                $isGoogleAuth = true;
            } else {
                $this->validateRegistrationData($data);

                $existingUser = $this->userRepository->findUserByEmail($data['email']);
                if ($existingUser) {
                    return $this->json(['errors' => ['An account with this email already exists.']], Response::HTTP_CONFLICT);
                }

                $user = $this->authService->createUserFromFormData($data, $fcmToken);
            }

            $result = $this->authService->generateTokens($user);
            $result['isGoogleAuth'] = $isGoogleAuth;
            $result['isAppleAuth'] = $isAppleAuth;
            $result['user'] = $this->userMapper->mapToDTO($user);

            return $this->json($result, JsonResponse::HTTP_CREATED);
        } catch (ValidationException $e) {
            return $this->json(['errors' => $e->getErrors()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    private function validateRegistrationData(array $data): void
    {
        $constraints = new Assert\Collection([
            'fields' => [
                'email' => [new Assert\NotBlank(), new Assert\Email()],
                'password' => [new Assert\NotBlank(), new Assert\Length(['min' => 8])],
                'firstName' => [new Assert\NotBlank()],
                'lastName' => [new Assert\NotBlank()],
                'locale' => new Assert\Optional([new Assert\Choice(['choices' => ['en', 'fr']])])
            ],
            'allowExtraFields' => true
        ]);

        $errors = $this->validator->validate($data, $constraints);
        if (count($errors) > 0) {
            throw new ValidationException($errors);
        }
    }
}
