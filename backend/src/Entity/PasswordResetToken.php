<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\PasswordResetTokenRepository;
use DateTimeImmutable;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: PasswordResetTokenRepository::class)]
class PasswordResetToken extends BaseEntity
{
    private const TOKEN_LENGTH = 32;
    private const EXPIRATION_INTERVAL = '+1 hour';

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private User $user;

    #[ORM\Column(type: 'string', length: 100)]
    private string $token;

    #[ORM\Column(type: 'datetime_immutable', name: 'expires_at')]  
    private DateTimeImmutable $expiresAt;

    #[ORM\Column(type: 'datetime_immutable', name: 'used_at', nullable: true)]
    private ?DateTimeImmutable $usedAt = null;

    public function __construct(User $user)
    {
        $this->user = $user;
        $this->token = bin2hex(random_bytes(self::TOKEN_LENGTH));
        $this->expiresAt = new DateTimeImmutable(self::EXPIRATION_INTERVAL);
    }

    public function isValid(): bool
    {
        return !$this->isUsed() && !$this->isExpired();
    }

    public function isUsed(): bool
    {
        return $this->usedAt !== null;
    }

    public function isExpired(): bool
    {
        return $this->expiresAt <= new DateTimeImmutable ();
    }

    public function getUser(): User
    {
        return $this->user;
    }

    public function setUser(User $user): self
    {
        $this->user = $user;
        return $this;
    }

    public function getToken(): string
    {
        return $this->token;
    }

    public function setToken(string $token): self
    {
        $this->token = $token;
        return $this;
    }

    public function getExpiresAt(): DateTimeImmutable 
    {
        return $this->expiresAt;
    }

    public function setExpiresAt(DateTimeImmutable $expiresAt): self
    {
        $this->expiresAt = $expiresAt;
        return $this;
    }

    public function getUsedAt(): ?DateTimeImmutable 
    {
        return $this->usedAt;
    }

    public function setUsedAt(?DateTimeImmutable $usedAt): self
    {
        $this->usedAt = $usedAt;
        return $this;
    }

    public function markAsUsed(): self
    {
        $this->usedAt = new DateTimeImmutable ();
        return $this;
    }
}
