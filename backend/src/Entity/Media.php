<?php

namespace App\Entity;

use App\Entity\Abstract\BaseEntity;
use App\Repository\MediaRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: MediaRepository::class)]
class Media extends BaseEntity
{
    const FALLBACK_MEDIA_GET_URL = "/api/media/";

    #[ORM\Column(length: 255)]
    private string $originalName;

    #[ORM\Column(length: 255, unique: true)]
    private string $fileName;

    #[ORM\Column(length: 255)]
    private string $storagePath; // Absolute path for deletion

    #[ORM\Column(length: 255)]
    private string $url; // Public URL for retrieval

    #[ORM\Column(length: 50)]
    private string $fileType; // Image, video, pdf, etc.

    #[ORM\Column(length: 100)]
    private string $mimeType;

    #[ORM\Column(type: 'integer')]
    private int $size; // File size in bytes

    #[ORM\Column(type: 'boolean')]
    private bool $isConfidential = false;

    public function getFileName(): string
    {
        return $this->fileName;
    }

    public function setFileName(string $fileName): self
    {
        $this->fileName = $fileName;
        return $this;
    }

    public function getOriginalName(): string
    {
        return $this->originalName;
    }

    public function setOriginalName(string $originalName): self
    {
        $this->originalName = $originalName;
        return $this;
    }

    public function getStoragePath(): string
    {
        return $this->storagePath;
    }

    public function setStoragePath(string $storagePath): self
    {
        $this->storagePath = $storagePath;
        return $this;
    }

    public function getUrl(): string
    {
        //TODO: move this logic to service/helper and (remove url)
        return $this->getMediaUrl();
        // return $this->url;
    }

    public function setUrl(string $url): self
    {
        $this->url = $url;
        return $this;
    }

    public function getFileType(): string
    {
        return $this->fileType;
    }

    public function setFileType(string $fileType): self
    {
        $this->fileType = $fileType;
        return $this;
    }

    public function getMimeType(): string
    {
        return $this->mimeType;
    }

    public function setMimeType(string $mimeType): self
    {
        $this->mimeType = $mimeType;
        return $this;
    }

    public function getSize(): int
    {
        return $this->size;
    }

    public function setSize(int $size): self
    {
        $this->size = $size;
        return $this;
    }

    public function isConfidential(): bool
    {
        return $this->isConfidential;
    }

    public function setIsConfidential(bool $isConfidential): self
    {
        $this->isConfidential = $isConfidential;
        return $this;
    }

    /**
     * Returns the media URL
     */
    private function getMediaUrl(): string
    {
        return self::FALLBACK_MEDIA_GET_URL . $this->getId();
    }
}
