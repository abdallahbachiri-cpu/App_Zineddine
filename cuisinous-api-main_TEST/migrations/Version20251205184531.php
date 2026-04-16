<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20251205184531 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE orders ADD tax_total NUMERIC(10, 2) NOT NULL DEFAULT 0.00');
        $this->addSql('ALTER TABLE orders ADD gross_total NUMERIC(10, 2) NOT NULL DEFAULT 0.00');
        $this->addSql('ALTER TABLE orders ADD applied_taxes JSON NOT NULL DEFAULT \'{}\'');
        $this->addSql('ALTER TABLE wallet_transaction ADD gross_amount NUMERIC(10, 2) DEFAULT NULL');
        $this->addSql('ALTER TABLE wallet_transaction ADD commission_amount NUMERIC(10, 2) DEFAULT NULL');
        $this->addSql('ALTER TABLE wallet_transaction ADD commission_rate NUMERIC(10, 2) DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE wallet_transaction DROP gross_amount');
        $this->addSql('ALTER TABLE wallet_transaction DROP commission_amount');
        $this->addSql('ALTER TABLE wallet_transaction DROP commission_rate');
        $this->addSql('ALTER TABLE "orders" DROP tax_total');
        $this->addSql('ALTER TABLE "orders" DROP gross_total');
        $this->addSql('ALTER TABLE "orders" DROP applied_taxes');
    }
}
