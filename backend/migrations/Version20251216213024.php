<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20251216213024 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE TABLE allergens (id UUID NOT NULL, created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, updated_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, name_fr VARCHAR(100) NOT NULL, name_en VARCHAR(100) NOT NULL, PRIMARY KEY(id))');
        $this->addSql('COMMENT ON COLUMN allergens.id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN allergens.created_at IS \'(DC2Type:datetime_immutable)\'');
        $this->addSql('COMMENT ON COLUMN allergens.updated_at IS \'(DC2Type:datetime_immutable)\'');
        $this->addSql('CREATE TABLE dish_allergens (dish_id UUID NOT NULL, allergen_id UUID NOT NULL, PRIMARY KEY(dish_id, allergen_id))');
        $this->addSql('CREATE INDEX IDX_BD8EDBE5148EB0CB ON dish_allergens (dish_id)');
        $this->addSql('CREATE INDEX IDX_BD8EDBE56E775A4A ON dish_allergens (allergen_id)');
        $this->addSql('COMMENT ON COLUMN dish_allergens.dish_id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN dish_allergens.allergen_id IS \'(DC2Type:uuid)\'');
        $this->addSql('ALTER TABLE dish_allergens ADD CONSTRAINT FK_BD8EDBE5148EB0CB FOREIGN KEY (dish_id) REFERENCES dish (id) ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE dish_allergens ADD CONSTRAINT FK_BD8EDBE56E775A4A FOREIGN KEY (allergen_id) REFERENCES allergens (id) ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE orders ALTER tax_total DROP DEFAULT');
        $this->addSql('ALTER TABLE orders ALTER gross_total DROP DEFAULT');
        $this->addSql('ALTER TABLE orders ALTER applied_taxes DROP DEFAULT');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE dish_allergens DROP CONSTRAINT FK_BD8EDBE5148EB0CB');
        $this->addSql('ALTER TABLE dish_allergens DROP CONSTRAINT FK_BD8EDBE56E775A4A');
        $this->addSql('DROP TABLE allergens');
        $this->addSql('DROP TABLE dish_allergens');
        $this->addSql('ALTER TABLE "orders" ALTER tax_total SET DEFAULT \'0.00\'');
        $this->addSql('ALTER TABLE "orders" ALTER gross_total SET DEFAULT \'0.00\'');
        $this->addSql('ALTER TABLE "orders" ALTER applied_taxes SET DEFAULT \'{}\'');
    }
}
