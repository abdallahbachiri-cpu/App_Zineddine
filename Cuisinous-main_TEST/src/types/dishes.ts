import { Category } from "./category";
interface Image {
    id: string;
    originalName: string;
    url: string;
    fileType: string;
  }

export interface Ingredient {
  nameEn: string;
  nameFr: string;
  id: string;
  name: string;
  description?: string;
}

export interface Allergen {
  id: string;
  nameEn: string;
  nameFr: string;
  name: string;
  requiresSpecification?: boolean;
}

export interface DishAllergen {
  id: string;
  dishId: string;
  allergenId: string;
  specification?: string;
}

export interface DishIngredient {
  id: string;
  nameEn: string;
  ingredientNameEn: string;
  ingredientNameFr: string;
  nameFr: string;
  price: number;
  ingredientId: string | null;
  isSupplement: boolean;
  available?: boolean;
  ingredient?: Ingredient; 
}

export interface Dish {
  id: string;
  name: string;
  foodStoreId: string;
  foodStoreName: string;
  description: string;
  price: number;
  available: boolean;
  averageRating: number;
  createdAt: string;
  updatedAt: string;
  gallery: Image[];
  ingredients?: DishIngredient[];
  categories?: Category[];
}
