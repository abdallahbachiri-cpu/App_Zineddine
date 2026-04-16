<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260224150002 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Update payout cooldown to hours and remove daily limits';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE payout_configuration ADD payout_cooldown_hours INT NOT NULL DEFAULT 24');
        $this->addSql('ALTER TABLE payout_configuration DROP daily_limit');
        $this->addSql('ALTER TABLE payout_configuration DROP payout_cooldown_minutes');
        $this->addSql('ALTER TABLE payout_configuration DROP max_daily_payout_count');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE payout_configuration ADD daily_limit NUMERIC(10, 2) NOT NULL');
        $this->addSql('ALTER TABLE payout_configuration ADD max_daily_payout_count INT NOT NULL');
        $this->addSql('ALTER TABLE payout_configuration RENAME COLUMN payout_cooldown_hours TO payout_cooldown_minutes');
    }
}
