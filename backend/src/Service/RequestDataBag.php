<?php

namespace App\Service;

use Symfony\Component\HttpFoundation\Request;

class RequestDataBag
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public static function fromRequest(Request $request): self
    {
        $data = json_decode($request->getContent(), true);
        return new self(is_array($data) ? $data : []);
    }

    public function get(string $key, mixed $default = null): mixed
    {
        return $this->data[$key] ?? $default;
    }

    public function all(): array
    {
        return $this->data;
    }

    public function has(string $key): bool
    {
        return array_key_exists($key, $this->data);
    }

    public function getString(string $key, string $default = ''): string
    {
        return (string) $this->get($key, $default);
    }

    public function getInt(string $key, int $default = 0): int
    {
        return (int) $this->get($key, $default);
    }

    public function getFloat(string $key, float $default = 0.0): float
    {
        return (float) $this->get($key, $default);
    }

    public function getBool(string $key, bool $default = false): bool
    {
        return filter_var($this->get($key, $default), FILTER_VALIDATE_BOOLEAN);
    }
}
