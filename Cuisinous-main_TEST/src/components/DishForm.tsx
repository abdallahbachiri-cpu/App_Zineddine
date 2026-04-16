import React, { useState } from "react";
import { ingredientsMockData } from "../mockData/ingredients";
interface Ingredient {
  id: string;
  name: string;
  price: number;
}

interface Dish {
  id: string;
  name: string;
  description: string;
  ingredients: { id: string; price: number }[];
  price: number;
  createdAt: string;
  images: [];
}

const DishForm: React.FC = () => {
  const [showForm, setShowForm] = useState(false); // Track form visibility
  const [showIngredientPopup, setShowIngredientPopup] = useState(false); // Track ingredient popup visibility

  const [ingredients, setIngredients] = useState<Ingredient[]>(ingredientsMockData);
  const [dish, setDish] = useState<Dish>({
    id: "",
    name: "",
    description: "",
    ingredients: [],
    price: 0,
    createdAt: new Date().toISOString(),
    images: [],
  });

  const [selectedImages, setSelectedImages] = useState<File[]>([null as any]); // Start with one image upload slot

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setDish({ ...dish, [e.target.name]: e.target.value });
  };

  const handleImageUpload = (
    e: React.ChangeEvent<HTMLInputElement>,
    index: number
  ) => {
    if (e.target.files && e.target.files.length > 0) {
      const updatedImages = [...selectedImages];
      updatedImages[index] = e.target.files[0];
      setSelectedImages(updatedImages);
    }
  };

  const addImageField = () => {
    setSelectedImages([...selectedImages, null as any]);
  };

  const handleIngredientChange = (ingredientId: string, change: number) => {
    setDish((prevDish) => {
      const existingIngredient = prevDish.ingredients.find(
        (ing) => ing.id === ingredientId
      );
      const updatedIngredients = existingIngredient
        ? prevDish.ingredients.map((ing) =>
            ing.id === ingredientId
              ? { ...ing, price: Math.max(ing.price + change, 0) }
              : ing
          )
        : [...prevDish.ingredients, { id: ingredientId, price: 1 }];

      return {
        ...prevDish,
        ingredients: updatedIngredients.filter((ing) => ing.price > 0),
      };
    });
  };

  const calculateTotalPrice = () => {
    return dish.ingredients
      .reduce((total, ing) => {
        const ingredient = ingredients.find((item) => item.id === ing.id);
        return total + (ingredient?.price || 0) * ing.price;
      }, 0)
      .toFixed(2);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (dish.name && dish.description && dish.ingredients.length > 0) {
      setDish({
        id: "",
        name: "",
        description: "",
        ingredients: [],
        price: 0,
        createdAt: new Date().toISOString(),
        images: [],
      });
      setShowForm(false); // Hide the form after submission

      alert("Dish added successfully!");
    } else {
      alert("Please fill in all fields and select at least one ingredient.");
    }
  };

  const handleAddIngredient = (name: string, price: number) => {
    const newIngredient = {
      id: `${ingredients.length + 1}`,
      name,
      price,
    };
    setIngredients([...ingredients, newIngredient]);
    setShowIngredientPopup(false); // Close the popup after adding
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      {!showForm ? (
        <button onClick={() => setShowForm(true)} className="mt-4">
          + Add Recipe
        </button>
      ) : (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="grid grid-cols-3 gap-4">
            {selectedImages.map((_, index) => (
              <div
                key={index}
                className="h-[200px] border-dashed border-[5px] border-[#000] p-4 rounded-xl"
              >
                <input
                  type="file"
                  onChange={(e) => handleImageUpload(e, index)}
                  className="hidden"
                  id={`image-upload-${index}`}
                />
                <label
                  htmlFor={`image-upload-${index}`}
                  className="cursor-pointer flex flex-col items-center justify-center h-full"
                >
                  {selectedImages[index] ? (
                    <img
                      src={URL.createObjectURL(selectedImages[index])}
                      alt={`Selected ${index}`}
                      className="h-32 w-full object-cover rounded-lg"
                    />
                  ) : (
                    <span className="text-gray-500">Add Recipe Photo</span>
                  )}
                </label>
              </div>
            ))}
          </div>

          <button
            type="button"
            onClick={addImageField}
            className="mt-4 border-2 border-dashed p-4 rounded-xl"
          >
            + Add Image
          </button>

          <form onSubmit={handleSubmit} className="mt-6 space-y-4">
            <div>
              <label>Recipe Name</label>
              <input
                type="text"
                name="name"
                value={dish.name}
                onChange={handleInputChange}
                className="w-full border px-4 py-2 rounded-md"
                placeholder="Enter your recipe name"
              />
            </div>
            <div>
              <label>Description</label>
              <textarea
                name="description"
                value={dish.description}
                onChange={handleInputChange}
                className="w-full border px-4 py-2 rounded-md"
                placeholder="Description"
              />
            </div>

            <div>
              <h3 className="font-semibold">Ingredients</h3>
              <button
                type="button"
                onClick={() => setShowIngredientPopup(true)}
                className="bg-blue-500 text-white py-2 px-4 rounded-md mb-4"
              >
                + Add Ingredient
              </button>
              <ul className="space-y-2">
                {ingredients.map((ingredient) => (
                  <li
                    key={ingredient.id}
                    className="flex items-center justify-between"
                  >
                    <span>
                      {ingredient.name} (${ingredient.price})
                    </span>
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() =>
                          handleIngredientChange(ingredient.id, -1)
                        }
                        className="px-2 py-1 bg-gray-200 rounded"
                      >
                        -
                      </button>
                      <span>
                        {dish.ingredients.find(
                          (ing) => ing.id === ingredient.id
                        )?.price || 0}
                      </span>
                      <button
                        type="button"
                        onClick={() => handleIngredientChange(ingredient.id, 1)}
                        className="px-2 py-1 bg-gray-200 rounded"
                      >
                        +
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
            <div>
              <strong>Recipe Price: ${calculateTotalPrice()}</strong>
            </div>
            <button
              type="submit"
              className="bg-green-500 text-white py-2 px-4 rounded-md"
            >
              Add Recipe
            </button>
          </form>

          {/* Ingredient Popup */}
          {showIngredientPopup && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
              <div className="bg-white p-6 rounded-lg w-full max-w-md">
                <h3 className="text-xl font-semibold mb-4">Add Ingredient</h3>
                <form
                  onSubmit={(e) => {
                    e.preventDefault();
                    const name = (e.target as any).ingredientName.value;
                    const price = parseFloat((e.target as any).ingredientPrice.value);
                    handleAddIngredient(name, price);
                  }}
                  className="space-y-4"
                >
                  <div>
                    <label>Ingredient Name</label>
                    <input
                      type="text"
                      name="ingredientName"
                      className="w-full border px-4 py-2 rounded-md"
                      placeholder="Enter ingredient name"
                      required
                    />
                  </div>
                  <div>
                    <label>Price</label>
                    <input
                      type="number"
                      name="ingredientPrice"
                      className="w-full border px-4 py-2 rounded-md"
                      placeholder="Enter price"
                      required
                    />
                  </div>
                  <div className="flex justify-end gap-2">
                    <button
                      type="button"
                      onClick={() => setShowIngredientPopup(false)}
                      className="bg-gray-500 text-white py-2 px-4 rounded-md"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="bg-green-500 text-white py-2 px-4 rounded-md"
                    >
                      Add Ingredient
                    </button>
                  </div>
                </form>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default DishForm;