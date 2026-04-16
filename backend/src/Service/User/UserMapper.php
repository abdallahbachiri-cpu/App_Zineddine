<?php

namespace App\Service\User;

use App\DTO\UserDTO;
use App\Entity\User;

class UserMapper
{
    public function mapToDTO(User $user): UserDTO
    {
        return new UserDTO(
            $user->getId(),
            $user->getFirstName(),
            $user->getLastName(),
            $user->getLocale(),
            $user->getRoles(),
            $user->isActive(),
            $user->isPhoneConfirmed(),
            $user->isEmailConfirmed(),
            $user->isDeleted(),
            $user->getGoogleId() !== null,
            $user->needsGoogleOnboarding(),
            $user->getCreatedAt(),
            $user->getUpdatedAt(),
            $user->getEmail(),
            $user->getType(),
            $user->getMiddleName(),
            $user->getPhoneNumber(),
            $user->getDeletedAt(),
            $user->getDefaultAddress(),
            $user->getProfileImage() ? $user->getProfileImage()->getUrl() : null
        );
    }

    // Map an array of User entities to an array of UserDTOs
    public function mapToDTOs(array $users): array
    {
        return array_map([$this, 'mapToDTO'], $users);
    }
}