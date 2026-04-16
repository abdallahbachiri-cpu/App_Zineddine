<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20251114184158 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE orders ADD tip_stripe_payment_intent_id VARCHAR(255) DEFAULT NULL');
        $this->addSql('ALTER TABLE orders ADD tip_paid_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL');
        $this->addSql('ALTER TABLE orders ADD tip_payment_status VARCHAR(255) DEFAULT NULL');
        $this->addSql('COMMENT ON COLUMN orders.tip_paid_at IS \'(DC2Type:datetime_immutable)\'');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE "orders" DROP tip_stripe_payment_intent_id');
        $this->addSql('ALTER TABLE "orders" DROP tip_paid_at');
        $this->addSql('ALTER TABLE "orders" DROP tip_payment_status');
    }
}
