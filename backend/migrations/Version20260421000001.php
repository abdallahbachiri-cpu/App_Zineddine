<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260421000001 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Remove Twilio proxy session fields from orders table';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE "orders" DROP COLUMN twilio_session_sid, DROP COLUMN twilio_buyer_participant_sid, DROP COLUMN twilio_seller_participant_sid');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE "orders" ADD twilio_session_sid VARCHAR(255) DEFAULT NULL, ADD twilio_buyer_participant_sid VARCHAR(255) DEFAULT NULL, ADD twilio_seller_participant_sid VARCHAR(255) DEFAULT NULL');
    }
}
