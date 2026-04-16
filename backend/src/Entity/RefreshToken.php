<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\RefreshTokenRepository;
use Doctrine\ORM\Mapping as ORM;


#[ORM\Entity(repositoryClass: RefreshTokenRepository::class)]
class RefreshToken extends BaseEntity
{
    #[ORM\Column(type: 'string', length: 255, unique: true)]
    private string $token;

    #[ORM\Column(type: 'datetime')]
    private \DateTime $expiresAt;

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private User $user;

    public function getToken(): string
    {
        return $this->token;
    }

    public function setToken(string $token): self
    {
        $this->token = $token;
        return $this;
    }

    public function getExpiresAt(): \DateTime
    {
        return $this->expiresAt;
    }

    public function setExpiresAt(\DateTime $expiresAt): self
    {
        $this->expiresAt = $expiresAt;
        return $this;
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

    public function isExpired(): bool
    {
        return $this->expiresAt < new \DateTime();
    }
}
