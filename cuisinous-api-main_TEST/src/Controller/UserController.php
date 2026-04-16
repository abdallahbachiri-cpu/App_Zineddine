<?php

namespace App\Controller;

use App\Controller\Abstract\BaseController;
use App\DTO\UserDTO;
use App\Entity\PasswordResetToken;
use App\Entity\User;
use App\Repository\RefreshTokenRepository;
use App\Service\User\UserService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use App\Exception\ValidationException;
use App\Helper\ValidationHelper;
use App\Repository\PasswordResetTokenRepository;
use App\Repository\UserRepository;
use App\Service\Email\EmailTemplateRenderer;
use App\Service\Mailer\MailService;
use App\Service\Media\MediaService;
use App\Service\User\UserMapper;
use Doctrine\ORM\EntityManagerInterface;
use DomainException;
use InvalidArgumentException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Model;
use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\Mailer\Mailer;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\PasswordHasher\PasswordHasherInterface;
use Symfony\Component\Validator\Constraints\Valid;
use Symfony\Contracts\Translation\TranslatorInterface;

#[Route('/api/user', name: 'user_')]
class UserController extends BaseController
{
    public function __construct(
        private UserService $userService,
        private RefreshTokenRepository $refreshTokenRepository,
        private UserRepository $userRepository,
        private PasswordResetTokenRepository $passwordResetTokenRepository,
        private EntityManagerInterface $entityManager,
        private ValidatorInterface $validator,
        private UserPasswordHasherInterface $passwordHasher,
        private MailService $mailService,
        private MediaService $mediaService,
        private UserMapper $userMapper,
        private EmailTemplateRenderer $emailTemplateRenderer,
        private TranslatorInterface $translator,
        private string $frontendPasswordResetUrl,
    ) {}


    #[Route('', name: 'info', methods: ['GET'])]
    #[OA\Get(
        summary: "Get the logged-in user's information",
        description: "Retrieves the profile details of the authenticated user.",
        tags: ["User - profile"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with user data",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 404, description: "User not found"),
        ]
    )]
    public function getUserInfo(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        $userDTO = $this->userMapper->mapToDTO($user);
        return $this->json($userDTO);
    }


    //common routes for authenticated users
    #[Route('/logout', name: 'logout', methods: ['POST'])]
    #[OA\Post(
        summary: "Logout user from all devices",
        description: "Logs out the authenticated user by revoking all refresh tokens associated with the user, effectively logging them out from all devices.",
        tags: ["Authentication"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Logout successful",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Logged out successfully from all devices.")
                    ]
                )
            ),
            new OA\Response(
                response: 401,
                description: "Unauthorized - User not authenticated",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "error", type: "string", example: "User not found.")
                    ]
                )
            )
        ]
    )]
    public function logout(): JsonResponse //logout from all devices
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found.'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        // Revoke all refresh tokens associated with the user (log out from all devices)
        $this->refreshTokenRepository->deleteByUser($user);

        return $this->json(['message' => 'Logged out successfully from all devices.'], JsonResponse::HTTP_OK);
    }

    #[Route('', name: 'update', methods: ['PATCH'])]
    #[OA\Patch(
        summary: "Update the logged-in user's profile",
        description: "Updates the profile of the authenticated user. Only provided fields will be updated. it's mainly used to update the user type the first time.",
        tags: ["User - profile"],
        requestBody: new OA\RequestBody(
            required: false,
            description: "User update payload (only provided fields will be updated)",
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: "phoneNumber",
                        type: "string",
                        nullable: true,
                        description: "Phone number in international format (optional)",
                        example: "+1234567890",
                        pattern: "^\\+?[0-9]+$"
                    ),
                    // new OA\Property(
                    //     property: "email",
                    //     type: "string",
                    //     format: "email",
                    //     nullable: true,
                    //     description: "Valid email address (optional)",
                    //     example: "user@example.com",
                    //     maxLength: 255
                    // ),
                    new OA\Property(
                        property: "firstName",
                        type: "string",
                        nullable: true,
                        description: "User's first name (optional)",
                        example: "John",
                        maxLength: 50
                    ),
                    new OA\Property(
                        property: "lastName",
                        type: "string",
                        nullable: true,
                        description: "User's last name (optional)",
                        example: "Doe",
                        maxLength: 50
                    ),
                    new OA\Property(
                        property: "middleName",
                        type: "string",
                        nullable: true,
                        description: "User's middle name (optional)",
                        example: "Michael",
                        maxLength: 255
                    ),
                    new OA\Property(
                        property: "type",
                        type: "string",
                        nullable: true,
                        description: "User type (optional)",
                        example: "seller",
                        enum: ['seller', 'buyer']
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Successful response with updated user data",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid request payload"),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 422, description: "Unprocessable entity - Business logic validation failed"),
        ]
    )]
    public function updateUser(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
        }
        $userId = $user->getId();

        try {
            $data = $this->getRequestData($request);

            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            return $this->userService->updateUser($userId, $data);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (NotFoundHttpException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_NOT_FOUND);
        } catch (DomainException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_UNPROCESSABLE_ENTITY);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }


    #[Route('/profile-image', name: 'upsert_profile_image', methods: ['POST'])]
    #[OA\Post(
        summary: "Upload or update profile image",
        description: "Uploads a new profile image for the authenticated user. If an image already exists, it will be replaced.",
        tags: ["User - profile"],
        requestBody: new OA\RequestBody(
            required: true,
            description: "Profile image file (multipart/form-data)",
            content: new OA\MediaType(
                mediaType: "multipart/form-data",
                schema: new OA\Schema(
                    properties: [
                        new OA\Property(property: "profileImage", type: "string", format: "binary", description: "Image file (max 2MB)")
                    ],
                    required: ["profileImage"]
                )
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Profile image uploaded successfully",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid file or missing required field"),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 500, description: "Internal server error - Upload failed"),
        ]
    )]
    public function upsertUserProfileImage(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();

        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
            // throw new NotFoundHttpException('User not found');
        }

        $data = $this->getRequestData($request);

        if ($data === null) {
            return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $constraints = new Assert\Collection([
            'fields' => [
                'profileImage' => [
                    new Assert\NotBlank(),
                    new Assert\Image([
                        'maxSize' => '2M'
                    ])
                ]
            ],
            'allowMissingFields' => false,
            'allowExtraFields' => false
        ]);

        $errors = $this->validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $formattedErrors = ValidationHelper::formatErrors($errors);
            return $this->json(['errors' => $formattedErrors], JsonResponse::HTTP_BAD_REQUEST);
        }

        if (array_key_exists('profileImage', $data)) {
            $file = $data['profileImage'];
            if ($file instanceof UploadedFile) {
                try {
                    $profileImageMedia = $this->mediaService->upload($file);
                    $user->setProfileImage($profileImageMedia);
                } catch (\Exception $e) {
                    return $this->json(['error' => 'Failed to upload media: ' . $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
                }
            }
        }

        $this->entityManager->flush();

        $userDTO = $this->userMapper->mapToDTO($user);

        return $this->json($userDTO);
    }

    #[Route('/profile-image', name: 'delete_profile_image', methods: ['DELETE'])]
    #[OA\Delete(
        summary: "Delete profile image",
        description: "Removes the profile image of the authenticated user.",
        tags: ["User - profile"],
        responses: [
            new OA\Response(
                response: 200,
                description: "Profile image deleted successfully",
                content: new OA\JsonContent(
                    ref: new Model(type: UserDTO::class, groups: ["default"])
                )
            ),
            new OA\Response(response: 404, description: "User not found"),
            new OA\Response(response: 500, description: "Internal server error - Deletion failed"),
        ]
    )]
    public function deleteUserProfileImage(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();

        if (!$user instanceof User) {
            return $this->json(['error' => 'User not found'], JsonResponse::HTTP_NOT_FOUND);
        }

        try {
            $oldProfileImage = $user->getProfileImage();
            if ($oldProfileImage !== null) {
                $this->mediaService->delete($oldProfileImage);
            }

            $user->setProfileImage(null);
            $this->entityManager->flush();

            $userDTO = $this->userMapper->mapToDTO($user);
            return $this->json($userDTO);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => 'Failed to delete profile image: ' . $e->getMessage()],
                JsonResponse::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }


    // @TODO: limit requests 
    #[Route('/password-reset/request', name: 'password_reset_request', methods: ['POST'])]
    #[OA\Post(
        summary: "Request password reset",
        description: "Initiates a password reset process by sending a reset link to the provided email address. The email is only sent if an account exists.",
        tags: ["Authentication"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "email", type: "string", format: "email", description: "Email address", example: "user@example.com")
                ],
                required: ["email"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Password reset email sent (or account not found)",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "If the email exists, a reset link has been sent")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid email or validation error"),
            new OA\Response(response: 500, description: "Internal server error"),
        ]
    )]
    public function requestPasswordReset(Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);
            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'email' => [
                        new Assert\NotBlank(),
                        new Assert\Email(),
                    ],
                ],
                'allowExtraFields' => false
            ]);

            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            $email = $data['email'];

            $user = $this->userRepository->findUserByEmail($email);

            if ($user instanceof User) {

                if ($user->isAvailable()) {
                    // active and not soft-deleted
                    // Invalidate any existing tokens
                    $this->passwordResetTokenRepository->invalidateUserTokens($user);

                    // Create and persist new token
                    $token = new PasswordResetToken($user);
                    $this->entityManager->persist($token);
                    $this->entityManager->flush();

                    $this->sendPasswordResetEmail($user, $token, $user->getLocale());
                }
            }
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\RuntimeException $e) {
            // return $this->json(['error' => 'An unexpected error occurred.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
            //dev
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An unexpected error occurred.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
        return $this->json(['message' => 'If the email exists, a reset link has been sent']);
    }

    #[Route('/password-reset/validate/{token}', name: 'password_reset_validate', methods: ['GET'])]
    #[OA\Get(
        summary: "Validate password reset token",
        description: "Validates a password reset token and returns the masked email address associated with it.",
        tags: ["Authentication"],
        parameters: [
            new OA\Parameter(
                name: "token",
                in: "path",
                required: true,
                description: "Password reset token",
                schema: new OA\Schema(type: "string")
            )
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: "Token is valid",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "email", type: "string", description: "Masked email address", example: "u***e@example.com")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid or expired token"),
        ]
    )]
    public function validatePasswordResetToken(string $token): JsonResponse
    {

        $resetToken = $this->passwordResetTokenRepository->findValidToken($token);

        if (!$resetToken instanceof PasswordResetToken) {
            return $this->json(['message' => 'Invalid or expired token'], Response::HTTP_BAD_REQUEST);
        }

        return $this->json([
            'email' => $this->maskEmail($resetToken->getUser()->getEmail())
        ]);
    }

    #[Route('/password-reset/confirm', name: 'password_reset_confirm', methods: ['POST'])]
    #[OA\Post(
        summary: "Confirm password reset",
        description: "Confirms password reset by validating the token and setting a new password.",
        tags: ["Authentication"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "token", type: "string", description: "Password reset token"),
                    new OA\Property(
                        property: "newPassword",
                        type: "string",
                        description: "New password (min 8 chars, must contain uppercase, lowercase, number, special char)",
                        example: "NewPassword123!"
                    )
                ],
                required: ["token", "newPassword"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Password reset successfully",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Password has been reset successfully")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid token or password validation failed"),
        ]
    )]
    public function confirmPasswordReset(Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);

            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'token' => [
                        new Assert\NotBlank(),
                        new Assert\Type('string'),
                    ],
                    'newPassword' => [
                        new Assert\NotBlank(),
                        new Assert\Type('string'),
                        new Assert\Length(['min' => 8]),
                        new Assert\Regex('/[A-Z]/', message: 'Password must contain at least one uppercase letter.'),
                        new Assert\Regex('/[a-z]/', message: 'Password must contain at least one lowercase letter.'),
                        new Assert\Regex('/[0-9]/', message: 'Password must contain at least one number.'),
                        new Assert\Regex('/[\W]/', message: 'Password must contain at least one special character.')
                    ],
                ],
                'allowExtraFields' => false
            ]);

            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            $token = $data['token'];
            $newPassword = $data['newPassword'];

            $resetToken = $this->passwordResetTokenRepository->findValidToken($token);
            if (!$resetToken instanceof PasswordResetToken) {
                throw new InvalidArgumentException('Invalid or expired token');
            }

            $user = $resetToken->getUser();

            $hashedPassword = $this->passwordHasher->hashPassword($user, $newPassword);
            $user->setPassword($hashedPassword);

            // Invalidate token
            $resetToken->markAsUsed();

            $this->entityManager->flush();

            return $this->json(['message' => 'Password has been reset successfully']);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        }
    }


    #[Route('/email-confirmation/send', name: 'email_confirmation_send', methods: ['POST'])]
    #[OA\Post(
        summary: "Send email confirmation",
        description: "Sends an email confirmation link to verify the user's email address.",
        tags: ["Authentication"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "email", type: "string", format: "email", description: "Email address", example: "user@example.com")
                ],
                required: ["email"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Confirmation email sent (or already confirmed)",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "If the email exists, a confirmation link has been sent")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid email or validation error"),
            new OA\Response(response: 500, description: "Internal server error"),
        ]
    )]
    public function sendEmailConfirmation(Request $request): JsonResponse
    {
        // @TODO limit requests 
        try {
            $data = $this->getRequestData($request);
            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'email' => [
                        new Assert\NotBlank(),
                        new Assert\Email(),
                    ],
                ],
                'allowExtraFields' => false
            ]);

            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            $user = $this->userRepository->findUserByEmail($data['email']);

            if (!$user instanceof User) {
                return $this->json(['message' => 'If the email exists, a confirmation link has been sent']);
            }

            if ($user->isEmailConfirmed()) {
                return $this->json(['message' => 'Email is already confirmed']);
            }

            $this->userService->sendConfirmationEmail(
                $user,
                $user->getLocale()
            );

            return $this->json(['message' => 'If the email exists, a confirmation link has been sent']);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'An unexpected error occurred.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/email-confirmation/verify', name: 'email_confirmation_confirm', methods: ['POST'])]
    #[OA\Post(
        summary: "Verify email confirmation token",
        description: "Verifies an email confirmation token and marks the user's email as confirmed.",
        tags: ["Authentication"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: "email", type: "string", format: "email", description: "Email address", example: "user@example.com"),
                    new OA\Property(property: "token", type: "string", description: "Email confirmation token")
                ],
                required: ["email", "token"]
            )
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: "Email successfully verified",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Email successfully verified")
                    ]
                )
            ),
            new OA\Response(response: 400, description: "Bad request - Invalid token or user not found"),
            new OA\Response(response: 500, description: "Internal server error"),
        ]
    )]
    public function verifyEmailConfirmationToken(Request $request): JsonResponse
    {
        try {
            $data = $this->getRequestData($request);
            if ($data == null) {
                return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
            }

            $constraints = new Assert\Collection([
                'fields' => [
                    'email' => [
                        new Assert\NotBlank(),
                        new Assert\Email(),
                    ],
                    'token' => [
                        new Assert\NotBlank(),
                        new Assert\Type('string'),
                    ],
                ],
                'allowExtraFields' => false
            ]);

            $errors = $this->validator->validate($data, $constraints);
            if (count($errors) > 0) {
                throw new ValidationException($errors);
            }

            $user = $this->userRepository->findUserByEmail($data['email']);

            if (!$user instanceof User) {
                throw new InvalidArgumentException('Invalid or expired token');
            }

            if (!$user->verifyEmailConfirmationToken($data['token'])) {
                throw new InvalidArgumentException('Invalid or expired verification token');
            }

            $user->setEmailConfirmed(true);
            $this->entityManager->flush();

            return $this->json(['message' => 'Email successfully verified']);
        } catch (InvalidArgumentException $e) {
            return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (ValidationException $e) {
            return new JsonResponse(['errors' => $e->getErrors()], JsonResponse::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return $this->json(['error' => 'Failed to verify email'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }
    }


    private function maskEmail(string $email): string
    {
        $parts = explode('@', $email);
        $username = $parts[0];
        $domain = $parts[1] ?? '';

        if (strlen($username) > 2) {
            $masked = substr($username, 0, 1) . '***' . substr($username, -1);
        } else {
            $masked = '***';
        }

        return $masked . '@' . $domain;
    }

    private function sendPasswordResetEmail(User $user, PasswordResetToken $token, string $locale = 'en'): void
    {
        $resetLink = $this->frontendPasswordResetUrl . '?token=' . $token->getToken();

        // $locale = $user->getLocale() ?? 'en'; // Default to English if locale not set
        // $locale = $this->translator->getLocale();
        // dd($locale);

        // Render email content using template
        $emailContent = $this->emailTemplateRenderer->renderPasswordResetEmail($user, $resetLink, $locale);
        // dd(["emailcontent" => $emailContent]);

        $subject = $this->translator->trans(
            'password_reset.subject',
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


    // #[Route('', name: 'get_all', methods: ['GET'])]
    // public function getAllUsers(Request $request): JsonResponse
    // {
    //     $limit = $request->query->get('limit', PaginationHelper::DEFAULT_LIMIT);
    //     $page = $request->query->get('page', 1);

    //     $sortBy = $request->query->get('sortBy', SortingHelper::DEFAULT_SORT_BY);
    //     $sortOrder = $request->query->get('sortOrder', SortingHelper::DEFAULT_SORT_ORDER);

    //     $search = $request->query->get('search', null);

    //     try {
    //         $data = $this->userService->getAllUsers($page, $limit, $sortBy, $sortOrder, $search);
    //         return $this->json($data);

    //     } catch (\InvalidArgumentException $e) {

    //         return $this->json(['error' => $e->getMessage()], JsonResponse::HTTP_BAD_REQUEST);
    //     }
    // }

    // #[Route('/available', name: 'get_available', methods: ['GET'])]
    // public function getAvailableUsers(Request $request): JsonResponse
    // {
    //     $limit = $request->query->get('limit', PaginationHelper::DEFAULT_LIMIT);
    //     $page = $request->query->get('page', 1);

    //     $data = $this->userService->getAvailableUsers($page, $limit);

    //     return $this->json($data);
    // }


    // #[Route('/{id}', name: 'get_one', methods: ['GET'])]
    // public function getUserById(string $id): JsonResponse
    // {
    //     $userDTO = $this->userService->getUserById($id);

    //     if ($userDTO === null) {
    //         return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
    //     }

    //     return $this->json($userDTO);
    // }

    // #[Route('/{id}', name: 'update', methods: ['PATCH'])]
    // public function updateUser(string $id, Request $request): JsonResponse
    // {

    //     $data = $this->getRequestData($request);

    //     if ($data == null) {
    //         return $this->json(['error' => 'Invalid request payload.'], JsonResponse::HTTP_BAD_REQUEST);
    //     }

    //     return $this->userService->updateUser($id, $data);
    // }

    // #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    // public function deleteUser(string $id): JsonResponse
    // {
    //     $deleted = $this->userService->softDeleteUser($id);

    //     if (!$deleted) {
    //         return $this->json(['error' => 'User not found'], Response::HTTP_NOT_FOUND);
    //     }

    //     return $this->json(['message' => 'User has been deleted (soft delete applied).']);
    // }

    // #[Route('/{id}/restore', name: 'restore', methods: ['POST'])]
    // public function restoreUser(string $id): JsonResponse
    // {
    //     [$data, $status] = $this->userService->restoreUser($id);

    //     return $this->json($data, $status);
    // }

    // #[Route('/{id}/activate', name: 'activate', methods: ['POST'])]
    // public function activateUser(string $id): JsonResponse
    // {
    //     [$data, $status] = $this->userService->activateUser($id);

    //     return $this->json($data, $status);
    // }

    // #[Route('/{id}/suspend', name: 'suspend', methods: ['POST'])]
    // public function suspendUser(string $id): JsonResponse
    // {
    //     [$data, $status] = $this->userService->suspendUser($id);

    //     return $this->json($data, $status);
    // }
}
