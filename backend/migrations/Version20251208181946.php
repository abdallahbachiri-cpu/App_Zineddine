<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20251208181946 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('UPDATE orders SET gross_total = ROUND(total_price + tax_total, 2)');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('UPDATE orders SET gross_total = "0.00"');
    }
}
