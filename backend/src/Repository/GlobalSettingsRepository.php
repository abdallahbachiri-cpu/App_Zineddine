<?php

namespace App\Repository;

use App\Entity\GlobalSettings;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<GlobalSettings>
 */
class GlobalSettingsRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, GlobalSettings::class);
    }

    public function get(string $key, string $default = ''): string
    {
        $setting = $this->find($key);
        return $setting ? $setting->getValue() : $default;
    }

    public function set(string $key, string $value, ?\App\Entity\User $updatedBy = null): GlobalSettings
    {
        $em = $this->getEntityManager();
        $setting = $this->find($key);

        if ($setting === null) {
            $setting = new GlobalSettings($key, $value);
        } else {
            $setting->setValue($value);
            $setting->setUpdatedAt(new \DateTimeImmutable());
        }

        if ($updatedBy !== null) {
            $setting->setUpdatedBy($updatedBy);
        }

        $em->persist($setting);
        $em->flush();

        return $setting;
    }
}
