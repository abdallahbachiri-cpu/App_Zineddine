<?php

namespace App\DTO;

use JsonSerializable;

class UserJwtDTO implements JsonSerializable
{
    public readonly string $id;
    public readonly ?string $email;
    public readonly ?string $type;
    public readonly array $roles;

    public function __construct(string $id, ?string $email, ?string $type, array $roles)
    {
        $this->id = $id;
        $this->email = $email;
        $this->type = $type;
        $this->roles = $roles;
    }

    /**
     * Converts the object to a format suitable for JWT payload.
     *
     * @return array
     */
    public function toJwtPayload(): array
    {
        return [
            'id' => $this->id,
            'email' => $this->email,
            'type' => $this->type,
            'roles' => $this->roles,
        ];
    }

    /**
     * Implements JsonSerializable for JSON encoding.
     *
     * @return array
     */
    public function jsonSerialize(): array
    {
        return $this->toJwtPayload();
    }
}
