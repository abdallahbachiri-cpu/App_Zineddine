import { useState } from "react";
import { Dish } from "../../types/menu";
import { useTranslation } from "react-i18next";

interface EditDishFormProps {
  dish: Dish;
  onClose: () => void;
  onUpdate: (id: string, data: Partial<Dish>) => Promise<void>;
}

const EditDishForm = ({ dish, onClose, onUpdate }: EditDishFormProps) => {
  const { t } = useTranslation();
  const [formData, setFormData] = useState<Partial<Dish>>({
    name: dish.name,
    description: dish.description,
    price: dish.price
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === "price" ? parseFloat(value) || 0 : value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await onUpdate(dish.id, formData);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div>
      <h2 className="text-xl font-bold mb-4">{t('dish.editForm.title')}</h2>
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="block text-gray-700 mb-2" htmlFor="name">
            {t('dish.editForm.fields.name')}
          </label>
          <input
            type="text"
            id="name"
            name="name"
            value={formData.name || ""}
            onChange={handleChange}
            className="w-full px-3 py-2 border rounded"
            required
          />
        </div>
        
        <div className="mb-4">
          <label className="block text-gray-700 mb-2" htmlFor="description">
            {t('dish.editForm.fields.description')}
          </label>
          <textarea
            id="description"
            name="description"
            value={formData.description || ""}
            onChange={handleChange}
            className="w-full px-3 py-2 border rounded"
            rows={3}
          />
        </div>
        
        <div className="mb-4">
          <label className="block text-gray-700 mb-2" htmlFor="price">
            {t('dish.editForm.fields.price')}
          </label>
          <input
            type="number"
            id="price"
            name="price"
            value={formData.price || 0}
            onChange={handleChange}
            className="w-full px-3 py-2 border rounded"
            min="0"
            step="0.01"
            required
          />
        </div>
        
        <div className="flex justify-end gap-2">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
            disabled={isSubmitting}
          >
            {t('dish.editForm.buttons.cancel')}
          </button>
          <button
            type="submit"
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            disabled={isSubmitting}
          >
            {isSubmitting ? t('dish.editForm.buttons.updating') : t('dish.editForm.buttons.update')}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EditDishForm;