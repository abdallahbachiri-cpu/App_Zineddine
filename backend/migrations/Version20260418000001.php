<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260418000001 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add commission fields to food_store and create global_settings table';
    }

    public function up(Schema $schema): void
    {
        // Add commission fields to food_store (only if they don't exist yet)
        $this->addSql('ALTER TABLE food_store ADD COLUMN IF NOT EXISTS commission_rate DOUBLE PRECISION NOT NULL DEFAULT 15.0');
        $this->addSql('ALTER TABLE food_store ADD COLUMN IF NOT EXISTS commission_override BOOLEAN NOT NULL DEFAULT FALSE');

        // Create global_settings table
        $this->addSql('
            CREATE TABLE IF NOT EXISTS global_settings (
                key VARCHAR(100) NOT NULL,
                value VARCHAR(500) NOT NULL,
                updated_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
                updated_by_id UUID DEFAULT NULL,
                PRIMARY KEY(key)
            )
        ');
        $this->addSql('COMMENT ON COLUMN global_settings.updated_by_id IS \'(DC2Type:uuid)\'');
        $this->addSql('ALTER TABLE global_settings ADD CONSTRAINT FK_global_settings_user FOREIGN KEY (updated_by_id) REFERENCES users (id) ON DELETE SET NULL NOT DEFERRABLE INITIALLY IMMEDIATE');

        // Seed default commission rate
        $this->addSql("INSERT INTO global_settings (key, value, updated_at) VALUES ('default_commission_rate', '15.0', NOW()) ON CONFLICT (key) DO NOTHING");
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE food_store DROP COLUMN IF EXISTS commission_rate');
        $this->addSql('ALTER TABLE food_store DROP COLUMN IF EXISTS commission_override');
        $this->addSql('DROP TABLE IF EXISTS global_settings');
    }
}
