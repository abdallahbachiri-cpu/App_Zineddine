<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20251218160844 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Insert mandatory food allergens (MAPAQ / Santé Canada) with FR/EN labels and specification flags';
    }

    public function up(Schema $schema): void
    {
        $this->addSql("
            INSERT INTO allergens (id, name_fr, name_en, requires_specification, created_at)
            VALUES
            (gen_random_uuid(), 'Arachides', 'Peanuts', false, NOW()),
            (gen_random_uuid(), 'Fruits à coque', 'Tree nuts', true, NOW()),
            (gen_random_uuid(), 'Graines de sésame', 'Sesame seeds', false, NOW()),
            (gen_random_uuid(), 'Blé ou triticale (gluten)', 'Wheat or triticale (gluten)', true, NOW()),
            (gen_random_uuid(), 'Œufs', 'Eggs', false, NOW()),
            (gen_random_uuid(), 'Lait', 'Milk', false, NOW()),
            (gen_random_uuid(), 'Soja', 'Soy', false, NOW()),
            (gen_random_uuid(), 'Poissons et fruits de mer', 'Fish and seafood', true, NOW()),
            (gen_random_uuid(), 'Graines de moutarde', 'Mustard seeds', false, NOW()),
            (gen_random_uuid(), 'Sulfites', 'Sulfites', false, NOW())
        ");
    }

    public function down(Schema $schema): void
    {
        $this->addSql("
            DELETE FROM allergens
            WHERE name_en IN (
                'Peanuts',
                'Tree nuts',
                'Sesame seeds',
                'Wheat or triticale (gluten)',
                'Eggs',
                'Milk',
                'Soy',
                'Fish and seafood',
                'Mustard seeds',
                'Sulfites'
            )
        ");
    }
}
