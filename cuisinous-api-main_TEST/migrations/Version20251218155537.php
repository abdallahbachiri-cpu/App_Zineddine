<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20251218155537 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE allergens ADD requires_specification BOOLEAN DEFAULT false NOT NULL');
        $this->addSql('ALTER TABLE dish_allergens DROP CONSTRAINT FK_BD8EDBE5148EB0CB');
        $this->addSql('ALTER TABLE dish_allergens DROP CONSTRAINT FK_BD8EDBE56E775A4A');
        $this->addSql('ALTER TABLE dish_allergens DROP CONSTRAINT dish_allergens_pkey');
        $this->addSql('ALTER TABLE dish_allergens ADD id UUID NOT NULL');
        $this->addSql('ALTER TABLE dish_allergens ADD created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL');
        $this->addSql('ALTER TABLE dish_allergens ADD updated_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL');
        $this->addSql('ALTER TABLE dish_allergens ADD specification TEXT DEFAULT NULL');
        $this->addSql('ALTER TABLE dish_allergens ALTER dish_id DROP NOT NULL');
        $this->addSql('ALTER TABLE dish_allergens ALTER allergen_id DROP NOT NULL');
        $this->addSql('COMMENT ON COLUMN dish_allergens.id IS \'(DC2Type:uuid)\'');
        $this->addSql('COMMENT ON COLUMN dish_allergens.created_at IS \'(DC2Type:datetime_immutable)\'');
        $this->addSql('COMMENT ON COLUMN dish_allergens.updated_at IS \'(DC2Type:datetime_immutable)\'');
        $this->addSql('ALTER TABLE dish_allergens ADD CONSTRAINT FK_BD8EDBE5148EB0CB FOREIGN KEY (dish_id) REFERENCES dish (id) NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE dish_allergens ADD CONSTRAINT FK_BD8EDBE56E775A4A FOREIGN KEY (allergen_id) REFERENCES allergens (id) NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE dish_allergens ADD PRIMARY KEY (id)');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE allergens DROP requires_specification');
        $this->addSql('ALTER TABLE dish_allergens DROP CONSTRAINT fk_bd8edbe5148eb0cb');
        $this->addSql('ALTER TABLE dish_allergens DROP CONSTRAINT fk_bd8edbe56e775a4a');
        $this->addSql('DROP INDEX dish_allergens_pkey');
        $this->addSql('ALTER TABLE dish_allergens DROP id');
        $this->addSql('ALTER TABLE dish_allergens DROP created_at');
        $this->addSql('ALTER TABLE dish_allergens DROP updated_at');
        $this->addSql('ALTER TABLE dish_allergens DROP specification');
        $this->addSql('ALTER TABLE dish_allergens ALTER dish_id SET NOT NULL');
        $this->addSql('ALTER TABLE dish_allergens ALTER allergen_id SET NOT NULL');
        $this->addSql('ALTER TABLE dish_allergens ADD CONSTRAINT fk_bd8edbe5148eb0cb FOREIGN KEY (dish_id) REFERENCES dish (id) ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE dish_allergens ADD CONSTRAINT fk_bd8edbe56e775a4a FOREIGN KEY (allergen_id) REFERENCES allergens (id) ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE');
        $this->addSql('ALTER TABLE dish_allergens ADD PRIMARY KEY (dish_id, allergen_id)');
    }
}
