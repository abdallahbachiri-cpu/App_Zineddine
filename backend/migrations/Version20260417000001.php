<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260417000001 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Create chat_messages table for buyer-seller messaging';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('
            CREATE TABLE chat_messages (
                id UUID NOT NULL,
                order_id UUID NOT NULL,
                sender_id UUID NOT NULL,
                receiver_id UUID NOT NULL,
                message TEXT NOT NULL,
                is_read BOOLEAN NOT NULL DEFAULT FALSE,
                created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
                updated_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
                PRIMARY KEY(id)
            )
        ');
        $this->addSql('COMMENT ON COLUMN chat_messages.id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN chat_messages.order_id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN chat_messages.sender_id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN chat_messages.receiver_id IS \'(DC2Type:uuid)\'');
        $this->addSql('CREATE INDEX idx_chat_order ON chat_messages (order_id)');
        $this->addSql('ALTER TABLE chat_messages ADD CONSTRAINT FK_chat_order FOREIGN KEY (order_id) REFERENCES "orders" (id) ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE chat_messages ADD CONSTRAINT FK_chat_sender FOREIGN KEY (sender_id) REFERENCES users (id) NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE chat_messages ADD CONSTRAINT FK_chat_receiver FOREIGN KEY (receiver_id) REFERENCES users (id) NOT DEFERRABLE INITIALLY IMMEDIATE');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE chat_messages DROP CONSTRAINT FK_chat_order');
        $this->addSql('ALTER TABLE chat_messages DROP CONSTRAINT FK_chat_sender');
        $this->addSql('ALTER TABLE chat_messages DROP CONSTRAINT FK_chat_receiver');
        $this->addSql('DROP TABLE chat_messages');
    }
}
