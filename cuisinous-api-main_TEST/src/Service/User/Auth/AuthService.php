<?php
namespace App\Service\User\Auth;

use App\DTO\UserJwtDTO;
use App\Entity\RefreshToken;
use App\Entity\User;
use App\Helper\ValidationHelper;
use App\Repository\RefreshTokenRepository;
use App\Repository\UserRepository;
use App\Service\User\UserService;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class AuthService
{
    public function __construct(
        private JWTTokenManagerInterface $jwtTokenManager,
        private RefreshTokenRepository $refreshTokenRepository,
        private UserRepository $userRepository,
        private UserPasswordHasherInterface $passwordHasher,
        private EntityManagerInterface $entityManager,
        private UserService $userService,
        private ValidationHelper $validationHelper,
        private int $tokenTtl
    ) {}
    
    public function isPasswordValid(User $user, string $password): bool
    {
        return $this->passwordHasher->isPasswordValid($user, $password);
    }

    public function captureFcmToken(User $user, string $fcmToken): void
    {
        $user->setFcmToken($fcmToken);
        $this->entityManager->flush();
    }

    public function generateTokens(User $user, bool $rememberMe = false): array
    {
        $userJwtDTO = new UserJwtDTO(
            $user->getId(),
            $user->getEmail(),
            $user->getType(),
            $user->getRoles()
        );
    
        $accessToken = $this->jwtTokenManager->createFromPayload($user, $userJwtDTO->toJwtPayload());
        
        // Revoke all existing refresh tokens
        $this->refreshTokenRepository->deleteByUser($user);

        $refreshToken = bin2hex(random_bytes(64));
        $refreshTokenExpiry = $rememberMe ? '+30 days' : '+7 days';

        $refreshTokenEntity = new RefreshToken();
        $refreshTokenEntity->setUser($user);
        $refreshTokenEntity->setToken($refreshToken);
        $refreshTokenEntity->setExpiresAt((new \DateTime())->modify($refreshTokenExpiry));
    
        $this->refreshTokenRepository->save($refreshTokenEntity);

        return [
            'accessToken' => $accessToken,
            'refreshToken' => $refreshToken,
            'expiresIn' => $this->tokenTtl,
        ];
    }

    public function createUserFromFormData(array $data, ?string $fcmToken = null): User
    {
        $this->entityManager->beginTransaction();

        try {
            $user = new User();
            $normalizedEmail = $this->validationHelper->normalizeEmail($data['email']);
            $user->setEmail($normalizedEmail);
            $user->setFirstName(trim($data['firstName']));
            $user->setLastName(trim($data['lastName']));
            $user->setLocale($data['locale'] ?? 'en');
            $user->setType($data['type'] ?? null);
            $user->setActive(true);
            
            if ($fcmToken) {
                $user->setFcmToken($fcmToken);
            }

            // Hash password
            $hashedPassword = $this->passwordHasher->hashPassword(
                $user,
                $data['password']
            );
            $user->setPassword($hashedPassword);

            $this->userRepository->save($user);
            
            try {
                $this->userService->sendConfirmationEmail($user, $user->getLocale());
            } catch (\Exception $e) {
                // Email failure doesn't block registration
            }

            $this->entityManager->commit();

            return $user;
        } catch (\Exception $e) {
            $this->entityManager->rollback();
            throw $e;
        }
    }

    public function createUserFromAppleData(array $appleData, ?string $fcmToken = null): User
    {
        $this->entityManager->beginTransaction();

        try {
            $user = new User();
            $normalizedEmail = $this->validationHelper->normalizeEmail($appleData['email']);
            $user->setEmail($normalizedEmail);
            $user->setFirstName($appleData['firstName']);
            $user->setLastName($appleData['lastName']);
            $user->setAppleId($appleData['appleId']);
            $user->setLocale($appleData['locale'] ?? 'en');
            $user->setType($appleData['type'] ?? null);
            $user->setEmailConfirmed(true);
            $user->setActive(true);
            $user->setIsGoogleOnboardingCompleted(false);

            if ($fcmToken) {
                $user->setFcmToken($fcmToken);
            }

            $this->userRepository->save($user);
            $this->entityManager->commit();

            return $user;
        } catch (\Exception $e) {
            $this->entityManager->rollback();
            throw $e;
        }
    }

    public function createUserFromGoogleData(array $googleData, ?string $fcmToken = null): User
    {
        $this->entityManager->beginTransaction();

        try {
            $user = new User();
            $normalizedEmail = $this->validationHelper->normalizeEmail($googleData['email']);
            $user->setEmail($normalizedEmail);
            $user->setFirstName($googleData['firstName']);
            $user->setLastName($googleData['lastName']);
            $user->setGoogleId($googleData['googleId']);
            $user->setLocale($googleData['locale'] ?? 'en');
            $user->setType($googleData['type'] ?? null);
            $user->setEmailConfirmed(true);
            $user->setActive(true);
            $user->setIsGoogleOnboardingCompleted(false);

            if ($fcmToken) {
                $user->setFcmToken($fcmToken);
            }

            $this->userRepository->save($user);
            $this->entityManager->commit();

            return $user;
        } catch (\Exception $e) {
            $this->entityManager->rollback();
            throw $e;
        }
    }
}