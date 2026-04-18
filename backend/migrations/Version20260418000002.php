<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260418000002 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add hasSignedVendorContract and contractSignedAt to users table';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE users ADD COLUMN IF NOT EXISTS has_signed_vendor_contract BOOLEAN NOT NULL DEFAULT FALSE');
        $this->addSql('ALTER TABLE users ADD COLUMN IF NOT EXISTS contract_signed_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE users DROP COLUMN IF EXISTS has_signed_vendor_contract');
        $this->addSql('ALTER TABLE users DROP COLUMN IF EXISTS contract_signed_at');
    }
}
