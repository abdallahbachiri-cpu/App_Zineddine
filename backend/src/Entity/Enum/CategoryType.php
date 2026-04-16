<?php

namespace App\Entity\Enum;

enum CategoryType: string
{
    case CUISINE = 'cuisine';
    case REGION = 'region';
    case DIETARY = 'dietary';
    case FEATURE = 'feature';
    case MEAL_TYPE = 'mealType';
    case ALLERGEN_SAFETY = 'allergenSafety';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }

    public static function isValid(string $type): bool
    {
        return in_array($type, self::values(), true);
    }

    public function labelEn(): string
    {
        return match($this) {
            self::CUISINE => 'Cuisine',
            self::REGION => 'Region',
            self::DIETARY => 'Dietary',
            self::FEATURE => 'Feature',
            self::MEAL_TYPE => 'Meal Type',
            self::ALLERGEN_SAFETY => 'Allergen Safety',
        };
    }

    public function labelFr(): string
    {
        return match($this) {
            self::CUISINE => 'Cuisine',
            self::REGION => 'Région',
            self::DIETARY => 'Régime alimentaire',
            self::FEATURE => 'Caractéristique',
            self::MEAL_TYPE => 'Type de repas',
            self::ALLERGEN_SAFETY => 'Sécurité des allergènes',
        };
    }

    public function getLabel(string $locale = 'en'): string
    {
        return match($locale) {
            'fr' => $this->labelFr(),
            default => $this->labelEn(),
        };
    }

    public static function getTranslatedTypes(): array
    {
        return array_map(
            fn(self $type) => [
                'value' => $type->value,
                'labelEn' => $type->labelEn(),
                'labelFr' => $type->labelFr()
            ],
            self::cases()
        );
    }
}