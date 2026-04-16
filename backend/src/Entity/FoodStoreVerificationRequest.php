<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Entity\Enum\StoreVerificationStatus;
use App\Repository\FoodStoreVerificationRequestRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: FoodStoreVerificationRequestRepository::class)]
class FoodStoreVerificationRequest extends BaseEntity
{
    public const ALLOWED_SORT_FIELDS = ['createdAt', 'updatedAt'];
    public const FILTERABLE_FIELDS = ['status', 'foodStore'];
    
    #[ORM\ManyToOne(targetEntity: FoodStore::class, inversedBy: 'verificationRequests')]
    #[ORM\JoinColumn(nullable: false)]
    private FoodStore $foodStore;

    #[ORM\ManyToMany(targetEntity: Media::class, cascade: ['persist'])]
    #[ORM\JoinTable(name: 'verification_request_documents')]
    #[ORM\JoinColumn(name: 'request_id', referencedColumnName: 'id')]
    #[ORM\InverseJoinColumn(name: 'media_id', referencedColumnName: 'id', unique: true)]
    private Collection $documents;

    #[ORM\Column(type: 'string', enumType: StoreVerificationStatus::class, options: ['default' => StoreVerificationStatus::Pending])]
    private StoreVerificationStatus $status = StoreVerificationStatus::Pending;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $adminComment = null;

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: true, onDelete: 'SET NULL')]
    private ?User $verifiedBy = null;

    public function __construct(FoodStore $foodStore)
    {
        $this->foodStore = $foodStore;
        $this->documents = new ArrayCollection();
    }

    public function getFoodStore(): FoodStore
    {
        return $this->foodStore;
    }

    public function setFoodStore(FoodStore $foodStore): self
    {
        $this->foodStore = $foodStore;
        return $this;
    }

    public function getDocuments(): Collection
    {
        return $this->documents;
    }

    public function addDocument(Media $document): self
    {
        if (!$this->documents->contains($document)) {
            $this->documents->add($document);
        }
        return $this;
    }

    public function removeDocument(Media $document): self
    {
        $this->documents->removeElement($document);
        return $this;
    }

    public function clearDocuments(): self
    {
        $this->documents->clear();
        return $this;
    }

    public function getStatus(): StoreVerificationStatus
    {
        return $this->status;
    }

    public function setStatus(StoreVerificationStatus $status): self
    {
        $this->status = $status;
        return $this;
    }

    public function getAdminComment(): ?string
    {
        return $this->adminComment;
    }

    public function setAdminComment(?string $adminComment): self
    {
        $this->adminComment = $adminComment;
        return $this;
    }
    
    public function getVerifiedBy(): ?User
    {
        return $this->verifiedBy;
    }

    public function setVerifiedBy(?User $verifiedBy): self
    {
        $this->verifiedBy = $verifiedBy;
        return $this;
    }
}
