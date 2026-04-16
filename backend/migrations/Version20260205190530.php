<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260205190530 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add partial index for confidential media';
    }

    public function up(Schema $schema): void
    {
        $this->addSql(
            'CREATE INDEX idx_media_confidential_true
             ON media (id)
             WHERE is_confidential = true'
        );
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP INDEX idx_media_confidential_true');
    }
}
