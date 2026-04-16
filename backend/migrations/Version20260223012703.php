<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260223012703 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Drop foodstore stripe_onboarding_completed_at column and related index on media table';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE food_store DROP stripe_onboarding_completed_at');
        $this->addSql('DROP INDEX idx_media_confidential_true');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('CREATE INDEX idx_media_confidential_true ON media (id) WHERE (is_confidential = true)');
        $this->addSql('ALTER TABLE food_store ADD stripe_onboarding_completed_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL');
        $this->addSql('COMMENT ON COLUMN food_store.stripe_onboarding_completed_at IS \'(DC2Type:datetime_immutable)\'');
    }
}
