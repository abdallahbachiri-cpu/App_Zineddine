<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\NotificationRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: NotificationRepository::class)]
#[ORM\Table(name: 'notifications')]
class Notification extends BaseEntity
{
    #[ORM\Column(type: 'string', length: 255)]
    private string $title;

    #[ORM\Column(type: 'text')]
    private string $body;

    #[ORM\ManyToOne(targetEntity: User::class, inversedBy: 'sentNotifications')]
    #[ORM\JoinColumn(nullable: false)]
    private User $sender;

    #[ORM\ManyToOne(targetEntity: User::class, inversedBy: 'receivedNotifications')]
    #[ORM\JoinColumn(nullable: false)]
    private User $receiver;

    #[ORM\Column(type: 'string', length: 255, nullable: true)]
    private ?string $titleFr = null;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $bodyFr = null;

    #[ORM\Column(type: 'boolean')]
    private bool $isShow = false;

    #[ORM\ManyToOne(targetEntity: Order::class)]
    #[ORM\JoinColumn(nullable: true)]
    private ?Order $order = null;

    public function getOrder(): ?Order
    {
        return $this->order;
    }

    public function setOrder(?Order $order): self
    {
        $this->order = $order;
        return $this;
    }

    public function getTitle(): string
    {
        return $this->title;
    }

    public function setTitle(string $title): self
    {
        $this->title = $title;
        return $this;
    }

    public function getBody(): string
    {
        return $this->body;
    }

    public function setBody(string $body): self
    {
        $this->body = $body;
        return $this;
    }

    public function getSender(): User
    {
        return $this->sender;
    }

    public function setSender(User $sender): self
    {
        $this->sender = $sender;
        return $this;
    }

    public function getReceiver(): User
    {
        return $this->receiver;
    }

    public function setReceiver(User $receiver): self
    {
        $this->receiver = $receiver;
        return $this;
    }

    public function isShow(): bool
    {
        return $this->isShow;
    }

    public function setIsShow(bool $isShow): self
    {
        $this->isShow = $isShow;
        return $this;
    }

    public function getTitleFr(): ?string
    {
        return $this->titleFr;
    }

    public function setTitleFr(?string $titleFr): self
    {
        $this->titleFr = $titleFr;
        return $this;
    }

    public function getBodyFr(): ?string
    {
        return $this->bodyFr;
    }

    public function setBodyFr(?string $bodyFr): self
    {
        $this->bodyFr = $bodyFr;
        return $this;
    }
}
