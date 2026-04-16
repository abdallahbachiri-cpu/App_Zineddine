<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;


final class Version20260306144018 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add is_active column to wallet table to support blocking/unblocking payouts';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE wallet ADD is_active BOOLEAN NOT NULL DEFAULT TRUE');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE wallet DROP is_active');
    }
}
