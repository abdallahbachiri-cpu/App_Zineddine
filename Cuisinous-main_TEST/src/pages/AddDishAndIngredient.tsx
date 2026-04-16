import React from 'react';
import DishForm from '../components/DishForm';
interface AddDishAndIngredientProps {
  userId: number; 
}

const AddDishAndIngredient: React.FC<AddDishAndIngredientProps> = () => {
  return (
    <div>
      <h2>Add Ingredients and Dishes</h2>
      <DishForm />
    </div>
  );
};

export default AddDishAndIngredient;
