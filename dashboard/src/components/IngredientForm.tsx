import React, { useState } from 'react';
import { ingredientsMockData } from '../mockData/ingredients';

interface Ingredient {
  id: string;
  name: string;
  price: number;
  isRemovable: boolean;
  description: string;
  userId: number; // Add userId field
}

interface IngredientFormProps {
  userId: number; // Accept userId as a prop
}

const IngredientForm: React.FC<IngredientFormProps> = ({ userId }) => {
  const [ingredient, setIngredient] = useState<Ingredient>({
    id: '',
    name: '',
    price: 0,
    isRemovable: false,
    description: '',
    userId: userId, // Set the userId from the prop
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setIngredient({ ...ingredient, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (ingredient.name && ingredient.description) {
      const newIngredient = { ...ingredient, id: `${ingredientsMockData.length + 1}` };
      ingredientsMockData.push(newIngredient);
      setIngredient({ id: '', name: '', price: 0, isRemovable:false, description: '', userId: userId });
      alert('Ingredient added successfully!');

    }
  };

  return (
    // <form onSubmit={handleSubmit}>
    //   <h3>Add New Ingredient</h3>
    //   <div>
    //     <label>Ingredient Name</label>
    //     <input
    //       type="text"
    //       name="name"
    //       value={ingredient.name}
    //       onChange={handleChange}
    //       placeholder="Enter ingredient name"
    //     />
    //   </div>
    //   <div>
    //     <label>Description</label>
    //     <input
    //       type="text"
    //       name="description"
    //       value={ingredient.description}
    //       onChange={handleChange}
    //       placeholder="Enter ingredient description"
    //     />
    //   </div>
    //   <button type="submit">Add Ingredient</button>
    // </form>
    <form
      onSubmit={handleSubmit}
      className="bg-white p-6 rounded-2xl shadow-md w-full max-w-sm mx-auto"
    >
      <h2 className="text-xl font-semibold text-center mb-4">Add Ingredient</h2>

      <div className="mb-4">
        <label htmlFor="name" className="block text-sm font-medium mb-1">
          Ingredient Name
        </label>
        <input
          type="text"
          id="name"
          name="name"
          value={ingredient.name}
          onChange={handleChange}
          placeholder="Enter your Ingredient"
          className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
        />
      </div>

      <div className="mb-4">
        <label htmlFor="price" className="block text-sm font-medium mb-1">
          Description
        </label>
        <input
          type="text"
          id="description"
          name="description"
          value={ingredient.description}
          onChange={handleChange}
          placeholder="Enter a description"
          className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
        />
      </div>

      <div className="mb-4">
        <label htmlFor="price" className="block text-sm font-medium mb-1">
          Ingredient Price
        </label>
        <input
          type="text"
          id="price"
          name="price"
          value={ingredient.price}
          onChange={handleChange}
          placeholder="Enter your Ingredient"
          className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
        />
      </div>

      <div className="mb-4 flex items-center">
        <input
          type="checkbox"
          id="isRemovable"
          name="isRemovable"
          checked={ingredient.isRemovable}
          onChange={handleChange}
          className="mr-2"
        />
        <label htmlFor="isRemovable" className="text-sm">
          Is Removable
        </label>
      </div>

      <button
        type="submit"
        className="w-full bg-green-500 text-white py-2 rounded-md font-semibold hover:bg-green-600 transition"
      >
        Save
      </button>
    </form>
  );
};

export default IngredientForm;
