<?php

namespace App\DTO;

use App\Entity\Media;
use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    title: "Media DTO",
    description: "Represents a media file with its metadata.",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid", description: "Unique identifier for the media file"),
        new OA\Property(property: "originalName", type: "string", description: "Original name of the uploaded file"),
        new OA\Property(property: "url", type: "string", format: "uri", description: "Public URL of the media file"),
        new OA\Property(property: "fileType", type: "string", description: "MIME type of the file (e.g., image/png, video/mp4)")
    ],
)]
class MediaDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly string $originalName;
    public readonly string $url;
    public readonly string $fileType;
    // public readonly string $fileName;
    // public readonly string $mimeType;
    // public readonly int $size;
    // public readonly \DateTimeImmutable $createdAt;
    // public readonly ?\DateTimeImmutable $updatedAt;

    public function __construct(
        string $id,
        string $originalName,
        string $url,
        string $fileType,
        // string $fileName,
        // string $mimeType,
        // int $size,
        // \DateTimeImmutable $createdAt,
        // ?\DateTimeImmutable $updatedAt
    ) {
        $this->id = $id;
        $this->originalName = $originalName;
        $this->url = $url;
        $this->fileType = $fileType;
        // $this->fileName = $fileName;
        // $this->mimeType = $mimeType;
        // $this->size = $size;
        // $this->createdAt = $createdAt;
        // $this->updatedAt = $updatedAt;
    }

    public static function createFromEntity(Media $media): self
    {
        return new self(
            $media->getId(),
            $media->getOriginalName(),
            $media->getUrl(),
            $media->getFileType(),
            // $media->getFileName(),
            // $media->getMimeType(),
            // $media->getSize(),
            // $media->getCreatedAt(),
            // $media->getUpdatedAt()
        );
    }

    // public function getFormattedCreatedAt(): string
    // {
    //     return $this->createdAt->format('Y-m-d\TH:i:sP');
    // }

    // public function getFormattedUpdatedAt(): ?string
    // {
    //     return $this->updatedAt?->format('Y-m-d\TH:i:sP');
    // }

    public function jsonSerialize(): array
    {
        return [
            'id' => $this->id,
            'originalName' => $this->originalName,
            'url' => $this->url,
            'fileType' => $this->fileType,
            // 'fileName' => $this->fileName,
            // 'mimeType' => $this->mimeType,
            // 'size' => $this->size,
            // 'createdAt' => $this->getFormattedCreatedAt(),
            // 'updatedAt' => $this->getFormattedUpdatedAt(),
        ];
    }
}