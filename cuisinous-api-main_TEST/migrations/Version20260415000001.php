<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260415000001 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add apple_id column to users table for Sign in with Apple support';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE users ADD apple_id VARCHAR(255) DEFAULT NULL');
        $this->addSql('CREATE UNIQUE INDEX UNIQ_1483A5E9E71C7521 ON users (apple_id)');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP INDEX UNIQ_1483A5E9E71C7521');
        $this->addSql('ALTER TABLE users DROP apple_id');
    }
}
