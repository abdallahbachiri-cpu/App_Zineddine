<?php

namespace App\Controller\Auth;

use App\Controller\Abstract\BaseController;
use App\DTO\UserDTO;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\HttpFoundation\Response;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;

use App\Entity\User;
use App\Repository\UserRepository;
use App\DTO\UserJwtDTO;
use App\Entity\RefreshToken;
use App\Helper\ValidationHelper;
use App\Repository\RefreshTokenRepository;
use App\Service\User\UserMapper;
use App\Service\GoogleOAuthService;
use App\Service\User\Auth\AuthService;
use App\Service\User\UserService;
use App\Service\AppleOAuthService;
use Doctrine\ORM\EntityManagerInterface;

#[Route('/api/auth', name: 'auth_')]
class AuthController extends BaseController
{
    private UserRepository $userRepository;
    private RefreshTokenRepository $refreshTokenRepository;
    private UserPasswordHasherInterface $passwordHasher;
    private JWTTokenManagerInterface $jwtTokenManager;
    private GoogleOAuthService $googleOAuthService;
    private AppleOAuthService $appleOAuthService;
    private UserMapper $userMapper;

    public function __construct(
        private UserService $userService,
        UserRepository $userRepository,
        RefreshTokenRepository $refreshTokenRepository,
        UserPasswordHasherInterface $passwordHasher,
        JWTTokenManagerInterface $jwtTokenManager,
        GoogleOAuthService $googleOAuthService,
        AppleOAuthService $appleOAuthService,
        UserMapper $userMapper,
        private EntityManagerInterface $entityManager,
        private AuthService $authService,
        private ValidationHelper $validationHelper
    ) {
        $this->userRepository = $userRepository;
        $this->refreshTokenRepository = $refreshTokenRepository;
        $this->passwordHasher = $passwordHasher;
        $this->jwtTokenManager = $jwtTokenManager;
        $this->googleOAuthService = $googleOAuthService;
        $this->appleOAuthService = $appleOAuthService;
        $this->userMapper = $userMapper;
    }

    #[Route('/login', name: 'login', methods: ['POST'])]
    #[OA\Post(
        summary: "Authenticate a user",
        description: "Authenticates a user using either email/password credentials or a Google OAuth token. Upon successful authentication, returns JWT access and refresh tokens along with user information. The 'rememberMe' flag extends the refresh token expiry to 30 days.",
        tags: ["Authentication"],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Login credentials - either email/password or googleToken",
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "email",
                        type: "string",
                        format: "email",
                        nullable: true,
                        description: "User email (required if not using googleToken)",
                        example: "user@example.com"
                    ),
                    new OA\Property(
                        property: "password",
                        type: "string",
                        nullable: true,
                        description: "User password, minimum 8 characters (required if not using googleToken)",
                        example: "securePassword123!"
                    ),
                    new OA\Property(
                        property: "googleToken",
                        type: "string",
                        nullable: true,
                        description: "Google OAuth token (alternative to email/password)",
                        example: "google-oauth-token"
                    ),
                    new OA\Property(
                        property: "rememberMe",
                        type: "boolean",
                        nullable: true,
                        description: "Extend refresh token expiry to 30 days (default: false = 7 days)",
                        example: true
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Login successful",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "accessToken",
                            type: "string",
                            description: "JWT access token for API requests",
                            example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                        ),
                        new OA\Property(
                            property: "refreshToken",
                            type: "string",
                            description: "Refresh token for obtaining new access tokens",
                            example: "a1b2c3d4e5f6g7h8i9j0..."
                        ),
                        new OA\Property(
                            property: "expiresIn",
                            type: "integer",
                            description: "Access token expiration time in seconds",
                            example: 3600
                        ),
                        new OA\Property(
                            property: "isGoogleAuth",
                            type: "boolean",
                            description: "Indicates if authentication was via Google OAuth",
                            example: false
                        ),
                        new OA\Property(
                            property: "user",
                            ref: new Model(type: UserDTO::class, groups: ["default"])
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid payload, format, or validation error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(
                                type: "string",
                                example: "Invalid email format."
                            )
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 401,
                description: "Unauthorized - Invalid email or password, or account deleted",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Invalid credentials."
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 403,
                description: "Forbidden - Account is inactive or suspended",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Account is inactive."
                        )
                    ]
                )
            )
        ]
    )]
    public function login(Request $request): JsonResponse
    {
        $data = $this->getRequestData($request);

        if ($data == null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $errorMessages = [];

        $isGoogleAuth = false;
        $isAppleAuth = false;

        if (isset($data['appleToken']) && is_string($data['appleToken'])) {
            try {
                $appleUserData = $this->appleOAuthService->validateAppleToken(
                    $data['appleToken'],
                    [
                        'email'     => $data['email'] ?? '',
                        'firstName' => $data['firstName'] ?? '',
                        'lastName'  => $data['lastName'] ?? '',
                    ]
                );
                $isAppleAuth = true;
            } catch (\Exception $e) {
                $errorMessages[] = 'Apple authentication failed.';
                return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
            }
        } elseif (isset($data['googleToken']) && is_string($data['googleToken'])) {
            try {
                $googleUserInfo = $this->googleOAuthService->fetchUserInfo($data['googleToken']);
                $isGoogleAuth = true;
            } catch (\Exception $e) {
                $errorMessages[] = 'Google authentication failed.';
                return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
            }
        }

        if ($isAppleAuth) {
            $email = $appleUserData['email'];
        } elseif ($isGoogleAuth) {
            if (!isset($googleUserInfo->email) || !is_string($googleUserInfo->email)) {
                $errorMessages[] = 'Incomplete user info from Google.';
                return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
            }
            $email = (string) $googleUserInfo->email;
        } else {
            if (!isset($data['email'], $data['password']) || !is_string($data['email']) || !is_string($data['password'])) {
                $errorMessages[] = 'Invalid input. Email and password are required.';
                return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
            }

            $email = $data['email'];
            $password = $data['password'];

            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errorMessages[] = 'Invalid email format.';
                return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
            }

            if (strlen($password) < 8) {
                $errorMessages[] = 'Password must be at least 8 characters long.';
                return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
            }
        }

        // For Apple: look up by appleId first, then fall back to email
        if ($isAppleAuth) {
            $user = $this->userRepository->findOneBy(['appleId' => $appleUserData['appleId']]);
            if (!$user instanceof User) {
                $user = $this->userRepository->findUserByEmail($email);
            }
        } else {
            $user = $this->userRepository->findUserByEmail($email);
        }

        if (!$user instanceof User) {
            return $this->json(['error' => 'Invalid credentials.'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        if ($isGoogleAuth || $isAppleAuth) {
            $validPassword = true;
        } else {
            $validPassword = $this->passwordHasher->isPasswordValid($user, $password);
        }


        if (!$validPassword || $user->isDeleted()) {
            return $this->json(['error' => 'Invalid credentials.'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        if (!$user->isActive()) {
            return $this->json(['error' => 'Account is inactive.'], JsonResponse::HTTP_FORBIDDEN);
        }

        // Generate the JWT token
        $userJwtDTO = new UserJwtDTO(
            $user->getId(),
            $user->getEmail(),
            $user->getType(),
            $user->getRoles()
        );

        $accessToken = $this->jwtTokenManager->createFromPayload($user, $userJwtDTO->toJwtPayload());
        $tokenTtl = $this->getParameter('lexik_jwt_authentication.token_ttl'); // In seconds

        // Revoke all existing refresh tokens for the user
        $this->refreshTokenRepository->deleteByUser($user);

        $rememberMe = false;

        if (isset($data['rememberMe']) && $data['rememberMe'] === true) {
            $rememberMe = true;
        }

        if ($rememberMe) {
            $refreshTokenExpiry = '+30 days'; // Extended expiry for "remember me"
        } else {
            $refreshTokenExpiry = '+7 days'; // Default expiry
        }

        $refreshToken = bin2hex(random_bytes(64)); // Generate a random token
        $refreshTokenEntity = new RefreshToken();
        $refreshTokenEntity->setUser($user);
        $refreshTokenEntity->setToken($refreshToken);
        $refreshTokenEntity->setExpiresAt((new \DateTime())->modify($refreshTokenExpiry));

        $this->refreshTokenRepository->save($refreshTokenEntity);

        $userDTO = $this->userMapper->mapToDTO($user);

        return $this->json([
            'accessToken' => $accessToken,
            'refreshToken' => $refreshToken,
            'expiresIn' => $tokenTtl,
            'isGoogleAuth' => $isGoogleAuth,
            'isAppleAuth' => $isAppleAuth,
            'user' => $userDTO,
        ], JsonResponse::HTTP_OK);
    }

    #[Route('/token/refresh', name: 'token_refresh', methods: ['POST'])]
    #[OA\Post(
        summary: "Refresh access token",
        description: "Generates a new access token using a valid refresh token. The refresh token must not be expired. Can be used to maintain user sessions without requiring re-authentication.",
        tags: ["Authentication"],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Refresh token payload",
            content: new OA\JsonContent(
                type: "object",
                required: ["refreshToken"],
                properties: [
                    new OA\Property(
                        property: "refreshToken",
                        type: "string",
                        description: "The refresh token received during login or previous registration",
                        example: "a1b2c3d4e5f6g7h8..."
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Access token refreshed successfully",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "accessToken",
                            type: "string",
                            description: "New JWT access token",
                            example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                        ),
                        new OA\Property(
                            property: "expiresIn",
                            type: "integer",
                            description: "Token expiration time in seconds",
                            example: 3600
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid or missing refresh token",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Refresh token is required."
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 401,
                description: "Unauthorized - Invalid, expired, or revoked refresh token, or user is inactive/deleted",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "error",
                            type: "string",
                            example: "Invalid or expired refresh token."
                        )
                    ]
                )
            )
        ]
    )]
    public function refreshToken(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (!is_array($data)) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (!$data || !isset($data['refreshToken']) || !is_string($data['refreshToken'])) {
            return $this->json(['error' => 'Refresh token is required.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $refreshToken = $data['refreshToken'];

        // Find the refresh token using the repository
        $refreshTokenEntity = $this->refreshTokenRepository->findOneBy(['token' => $refreshToken]);

        if (!$refreshTokenEntity instanceof RefreshToken || $refreshTokenEntity->getExpiresAt() < new \DateTime()) {
            return $this->json(['error' => 'Invalid or expired refresh token.'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        $user = $refreshTokenEntity->getUser();

        if (!$user instanceof User || !$user->isAvailable()) {
            return $this->json(['error' => 'User is inactive or deleted.'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        // Generate a new access token
        $userJwtDTO = new UserJwtDTO(
            $user->getId(),
            $user->getEmail(),
            $user->getType(),
            $user->getRoles()
        );

        $accessToken = $this->jwtTokenManager->createFromPayload($user, $userJwtDTO->toJwtPayload());
        $tokenTtl = $this->getParameter('lexik_jwt_authentication.token_ttl');

        return $this->json([
            'accessToken' => $accessToken,
            'expiresIn' => $tokenTtl,
        ], JsonResponse::HTTP_OK);
    }


    #[Route('/register', name: 'register', methods: ['POST'])]
    #[OA\Post(
        summary: "Register a new user",
        description: "Creates a new user account either via Google OAuth token or traditional email/password registration. For email/password registration, the password must meet complexity requirements (uppercase, lowercase, digit, special character). A confirmation email is sent for traditional registration. Upon successful registration, the user is automatically authenticated and JWT tokens are returned.",
        tags: ["Authentication"],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Registration data - either googleToken or email/password/firstName/lastName",
            content: new OA\JsonContent(
                type: "object",
                properties: [
                    new OA\Property(
                        property: "googleToken",
                        type: "string",
                        nullable: true,
                        description: "Google OAuth token (alternative to email/password registration)"
                    ),
                    new OA\Property(
                        property: "email",
                        type: "string",
                        format: "email",
                        nullable: true,
                        description: "User email address (required for traditional registration, max 255 chars)",
                        example: "user@example.com"
                    ),
                    new OA\Property(
                        property: "password",
                        type: "string",
                        nullable: true,
                        description: "Password (required for traditional registration). Must contain: uppercase, lowercase, digit, special character, min 8 characters",
                        example: "SecurePassword123!"
                    ),
                    new OA\Property(
                        property: "firstName",
                        type: "string",
                        nullable: true,
                        description: "User's first name (required for traditional registration, max 50 chars)",
                        example: "John"
                    ),
                    new OA\Property(
                        property: "lastName",
                        type: "string",
                        nullable: true,
                        description: "User's last name (required for traditional registration, max 50 chars)",
                        example: "Doe"
                    ),
                    new OA\Property(
                        property: "locale",
                        type: "string",
                        nullable: true,
                        enum: ["en", "fr"],
                        description: "User's preferred locale for emails and UI (default: 'en')",
                        example: "en"
                    ),
                    new OA\Property(
                        property: "rememberMe",
                        type: "boolean",
                        nullable: true,
                        description: "Extend refresh token expiry to 30 days (default: false = 7 days)",
                        example: true
                    )
                ],
                required: []
            )
        ),
        responses: [
            new OA\Response(
                // response: 201,
                response: 200,
                description: "User successfully registered and authenticated",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "accessToken",
                            type: "string",
                            description: "JWT access token",
                            example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                        ),
                        new OA\Property(
                            property: "refreshToken",
                            type: "string",
                            description: "Refresh token for obtaining new access tokens",
                            example: "a1b2c3d4e5f6g7h8i9j0..."
                        ),
                        new OA\Property(
                            property: "expiresIn",
                            type: "integer",
                            description: "Access token expiration time in seconds",
                            example: 3600
                        ),
                        new OA\Property(
                            property: "isGoogleAuth",
                            type: "boolean",
                            description: "Indicates if registration was via Google OAuth",
                            example: false
                        ),
                        new OA\Property(
                            property: "user",
                            ref: new Model(type: UserDTO::class, groups: ["default"])
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid data, validation error, or password complexity requirements not met",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string"),
                            example: [
                                "Invalid request payload.",
                                "Password must contain at least one uppercase letter."
                            ]
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 409,
                description: "Conflict - Email or Google account already exists",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string"),
                            example: ["An account with this email already exists."]
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 500,
                description: "Internal server error",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(type: "string"),
                            example: ["Registration failed. Please try again."]
                        )
                    ]
                )
            )
        ]
    )]
    public function createUser(
        Request $request,
        ValidatorInterface $validator
    ): JsonResponse {
        // $errorMessages = [];
        try {
            $data = $this->getRequestData($request);
            if ($data === null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            if (isset($data['appleToken']) && is_string($data['appleToken'])) {
                return $this->handleAppleRegistration($data['appleToken'], $data);
            } elseif (isset($data['googleToken']) && is_string($data['googleToken'])) {
                return $this->handleGoogleRegistration($data['googleToken']);
            } else {
                return $this->handleTraditionalRegistration($data, $validator);
            }
        } catch (\Exception $e) {
            return $this->json(
                ['errors' => ['Registration failed. Please try again.']],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }

    private function handleAppleRegistration(string $appleToken, array $data): JsonResponse
    {
        try {
            $appleData = $this->appleOAuthService->validateAppleToken(
                $appleToken,
                [
                    'email'     => $data['email'] ?? '',
                    'firstName' => $data['firstName'] ?? '',
                    'lastName'  => $data['lastName'] ?? '',
                ]
            );

            // Check for existing account by Apple ID
            $existingUser = $this->userRepository->findOneBy(['appleId' => $appleData['appleId']]);
            if ($existingUser) {
                return $this->json(
                    ['errors' => ['An account associated with this Apple ID already exists.']],
                    Response::HTTP_CONFLICT
                );
            }

            // Check for existing account by email (e.g. user previously signed up with email)
            $existingByEmail = $this->userRepository->findUserByEmail($appleData['email']);
            if ($existingByEmail instanceof User) {
                // Link the Apple ID to the existing account instead of creating a new one
                $existingByEmail->setAppleId($appleData['appleId']);
                $this->entityManager->flush();
                return $this->generateRegistrationSuccessResponse($existingByEmail, false, true);
            }

            $appleData['locale'] = $data['local'] ?? 'en';
            $fcmToken = $data['fcm_token'] ?? null;
            $user = $this->authService->createUserFromAppleData($appleData, $fcmToken);

            return $this->generateRegistrationSuccessResponse($user, false, true);
        } catch (\Exception $e) {
            return $this->json(
                ['errors' => [$e->getMessage()]],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }
    }

    private function handleGoogleRegistration(string $googleToken): JsonResponse
    {
        try {
            $googleData = $this->googleOAuthService->validateGoogleToken($googleToken);

            // Check if user exists with this Google ID
            $existingUser = $this->userRepository->findOneBy(['googleId' => $googleData['googleId']]);
            if ($existingUser) {
                return $this->json(
                    ['errors' => ['An account associated with this Google account already exists.']],
                    Response::HTTP_CONFLICT
                );
            }

            $user = $this->authService->createUserFromGoogleData($googleData);

            return $this->generateRegistrationSuccessResponse($user, true);
        } catch (\Exception $e) {
            return $this->json(
                ['errors' => [$e->getMessage()]],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }
    }

    private function handleTraditionalRegistration(array $data, ValidatorInterface $validator): JsonResponse
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

        $errors = $validator->validate($data, $constraints);
        if (count($errors) > 0) {
            return $this->json(
                ['errors' => ValidationHelper::formatErrors($errors)],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $email = $data['email'];

        $normalizedEmail = $this->validationHelper->normalizeEmail($email);

        if (!$this->validationHelper->isAllowedEmailDomain($normalizedEmail)) {
            return $this->json(
                ['errors' => ['Please use a supported email provider (Gmail, Yahoo, Outlook, etc.).']],
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $existingUser = $this->userRepository->findUserByEmail($email);

        if ($existingUser instanceof User) {
            return $this->json(
                ['errors' => ['An account with this email already exists.']],
                Response::HTTP_CONFLICT
            );
        }

        $data['email'] = $normalizedEmail; // Ensure normalized email is used
        $user = $this->authService->createUserFromFormData($data);

        return $this->generateRegistrationSuccessResponse($user);
    }


    private function generateRegistrationSuccessResponse(
        User $user,
        bool $isGoogleAuth = false,
        bool $isAppleAuth = false
    ): JsonResponse {
        $tokens = $this->authService->generateTokens($user, true);
        $userDTO = $this->userMapper->mapToDTO($user);

        return $this->json([
            'accessToken' => $tokens['accessToken'],
            'refreshToken' => $tokens['refreshToken'],
            'expiresIn' => $tokens['expiresIn'],
            'isGoogleAuth' => $isGoogleAuth,
            'isAppleAuth' => $isAppleAuth,
            'user' => $userDTO,
        ], JsonResponse::HTTP_OK);
    }

    #[Route('/google/callback', name: 'google_callback', methods: ['GET'])]
    #[OA\Get(
        summary: "Handle Google OAuth callback",
        description: "Exchanges the Google authorization code for a Google access token. This endpoint is called by the frontend after the user authenticates via Google OAuth. The returned googleAccessToken is then used in login or register endpoints.",
        tags: ["Authentication"],
        parameters: [
            new OA\Parameter(
                name: "code",
                in: "query",
                required: true,
                description: "Authorization code received from Google OAuth redirected back to the application",
                schema: new OA\Schema(type: "string"),
                example: "4/0Ad9..."
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Google authentication successful - authorization code exchanged for access token",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "googleAccessToken",
                            type: "string",
                            description: "Google OAuth access token to be used in login/register requests",
                            example: "ya29.a0AfH6SM..."
                        )
                    ]
                )
            ),
            new OA\Response(
                response: 400,
                description: "Bad request - Invalid authorization code or Google authentication failed",
                content: new OA\JsonContent(
                    type: "object",
                    properties: [
                        new OA\Property(
                            property: "errors",
                            type: "array",
                            items: new OA\Items(
                                type: "string",
                                example: "Google authentication failed."
                            )
                        )
                    ]
                )
            )
        ]
    )]
    public function googleCallback(Request $request): JsonResponse
    {
        // $data = json_decode($request->getContent(), true);
        $authorizationCode = $request->query->get('code');

        $errorMessages = [];

        // if (!is_array($data)) {
        //     $errorMessages[] = 'Invalid request payload.';
        //     return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
        // }

        // $authorizationCode = $data['code'];

        try {
            $accessToken = $this->googleOAuthService->fetchAccessToken($authorizationCode);
            return $this->json(['googleAccessToken' => $accessToken]);
            // or redirect to frotnend url with the google access token as query param
        } catch (\Exception $e) {
            // dd($e->getMessage());
            $errorMessages[] = 'Google authentication failed.';
            return $this->json(['errors' => $errorMessages], JsonResponse::HTTP_BAD_REQUEST);
        }
    }
}
