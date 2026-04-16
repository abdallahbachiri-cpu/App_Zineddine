<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260407005814 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE TABLE notifications (id UUID NOT NULL, sender_id UUID NOT NULL, receiver_id UUID NOT NULL, order_id UUID DEFAULT NULL, created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, updated_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, title VARCHAR(255) NOT NULL, title_fr VARCHAR(255) DEFAULT NULL, body TEXT NOT NULL, body_fr TEXT DEFAULT NULL, is_show BOOLEAN NOT NULL, PRIMARY KEY(id))');
        $this->addSql('CREATE INDEX IDX_6000B0D3F624B39D ON notifications (sender_id)');
        $this->addSql('CREATE INDEX IDX_6000B0D3CD53EDB6 ON notifications (receiver_id)');
        $this->addSql('CREATE INDEX IDX_6000B0D38D9F6D38 ON notifications (order_id)');
        $this->addSql('COMMENT ON COLUMN notifications.id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN notifications.sender_id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN notifications.receiver_id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN notifications.order_id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN notifications.created_at IS \'(DC2Type:datetime_immutable)\'');
        $this->addSql('COMMENT ON COLUMN notifications.updated_at IS \'(DC2Type:datetime_immutable)\'');
        $this->addSql('ALTER TABLE notifications ADD CONSTRAINT FK_6000B0D3F624B39D FOREIGN KEY (sender_id) REFERENCES users (id) NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE notifications ADD CONSTRAINT FK_6000B0D3CD53EDB6 FOREIGN KEY (receiver_id) REFERENCES users (id) NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE notifications ADD CONSTRAINT FK_6000B0D38D9F6D38 FOREIGN KEY (order_id) REFERENCES "orders" (id) NOT DEFERRABLE INITIALLY IMMEDIATE');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE notifications DROP CONSTRAINT FK_6000B0D3F624B39D');
        $this->addSql('ALTER TABLE notifications DROP CONSTRAINT FK_6000B0D3CD53EDB6');
        $this->addSql('ALTER TABLE notifications DROP CONSTRAINT FK_6000B0D38D9F6D38');
        $this->addSql('DROP TABLE notifications');
    }
}
