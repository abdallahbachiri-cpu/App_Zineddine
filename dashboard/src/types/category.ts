export interface Category {
    id: string;
    nameEn: string;
    nameFr: string;
    type: 'INGREDIENT' | 'DISH';
    createdAt?: string;
    updatedAt?: string;
  }
  
  export interface CategoryCreateDTO {
    nameEn: string;
    nameFr: string;
    type: 'INGREDIENT' | 'DISH';
  }
  
  export interface CategoryUpdateDTO {
    nameEn?: string;
    nameFr?: string;
    type?: 'INGREDIENT' | 'DISH';
  }
  
  export interface CategoryType {
    value: 'INGREDIENT' | 'DISH';
    label: string;
  }