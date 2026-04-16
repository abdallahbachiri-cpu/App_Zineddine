<?php

namespace App\Service\Media;

use App\DTO\MediaDTO;
use App\Entity\Media;

class MediaMapper
{
    public function mapToDTO(Media $media): MediaDTO
    {
        return new MediaDTO(
            $media->getId(),
            $media->getOriginalName(),
            $media->getUrl(),
            $media->getFileType(),
            // $media->getCreatedAt(),
            // $media->getUpdatedAt()
        );
    }

    public function mapToDTOs(array $mediaCollection): array
    {
        return array_map([$this, 'mapToDTO'], $mediaCollection);
    }
}
