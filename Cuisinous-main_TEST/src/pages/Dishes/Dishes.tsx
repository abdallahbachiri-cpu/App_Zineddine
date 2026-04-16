import { useEffect, useState, useRef } from "react";
import { Dish } from "../../types/dishes";
import {
  getDishes,
  createDish,
  deleteDish,
  updateDish,
  getCategories,
  getCategoryTypes,
  addDishCategory,
  removeDishCategory,
  getDishById,
  activateDish,
  deactivateDish
} from "../../services/disheService";
import { useTranslation } from "react-i18next";
import AddDishForm from "../../components/AddDishForm";
import EditDishForm from "../../components/Dish/EditDishForm";
import API_BASE_URL from "../../config/apiConfig";
import { Link } from "react-router-dom";
import {
  Table,
  Button,
  Modal,
  Spin,
  Space,
  Card,
  Image,
  Tag,
  Carousel,
  message,
  Select,
} from "antd";
import type { ColumnsType } from "antd/es/table";
import { LeftOutlined, RightOutlined } from "@ant-design/icons";
import {
  EditOutlined,
  DeleteOutlined,
  EyeOutlined,
  PlusOutlined,
  ExclamationCircleFilled,
} from "@ant-design/icons";
const { confirm } = Modal;

const Dishes = () => {
  const [dishes, setDishes] = useState<Dish[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddForm, setShowAddForm] = useState(false);
  const [showEditForm, setShowEditForm] = useState(false);
  const [dishToEdit, setDishToEdit] = useState<Dish | null>(null);
  const { t } = useTranslation();

  useEffect(() => {
    fetchDishes();
  }, []);

  const fetchDishes = async () => {
    try {
      const data = await getDishes();
      setDishes(data);
    } catch (err: any) {
      message.error(t("dishes.messages.fetchError"));
    } finally {
      setLoading(false);
    }
  };

  const handleAddDish = async (dishData: Omit<Dish, "id">, files: File[]) => {
    try {
      const newDish = await createDish(dishData, files);
      setDishes([...dishes, newDish]);
      setShowAddForm(false);
      message.success(t("dishes.messages.createSuccess"));
    } catch (err) {
      message.error(t("dishes.messages.createError"));
      throw err;
    }
  };

  const handleEditClick = (dish: Dish) => {
    setDishToEdit(dish);
    setShowEditForm(true);
  };

  const handleUpdateDish = async (id: string, dishData: Partial<Dish>) => {
    try {
      const updatedDish = await updateDish(id, dishData);
      setDishes(dishes.map((dish) => (dish.id === id ? updatedDish : dish)));
      setShowEditForm(false);
      message.success(t("dishes.messages.updateSuccess"));
    } catch (err) {
      console.error("Failed to update dish:", err);
      message.error(t("dishes.messages.updateError"));
      throw err;
    }
  };

  const handleDeleteClick = (id: string) => {
    confirm({
      title: t("dishes.deleteConfirm.title"),
      icon: <ExclamationCircleFilled />,
      content: t("dishes.deleteConfirm.content"),
      okText: t("dishes.deleteConfirm.okText"),
      okType: "danger",
      cancelText: t("dishes.deleteConfirm.cancelText"),
      onOk() {
        return deleteDish(id)
          .then(() => {
            setDishes(dishes.filter((dish) => dish.id !== id));
            message.success(t("dishes.messages.deleteSuccess"));
          })
          .catch((err) => {
            console.error("Failed to delete dish:", err);
            message.error(t("dishes.messages.deleteError"));
          });
      },
    });
  };

  const handleActivateDish = async (id: string) => {
    try {
      const updatedDish = await activateDish(id);
      setDishes(dishes.map((dish) => (dish.id === id ? updatedDish : dish)));
      message.success(t("dishes.messages.activateSuccess"));
    } catch (err) {
      console.error("Failed to activate dish:", err);
      message.error(t("dishes.messages.activateError"));
    }
  };

  const handleDeactivateDish = async (id: string) => {
    try {
      const updatedDish = await deactivateDish(id);
      setDishes(dishes.map((dish) => (dish.id === id ? updatedDish : dish)));
      message.success(t("dishes.messages.deactivateSuccess"));
    } catch (err) {
      console.error("Failed to deactivate dish:", err);
      message.error(t("dishes.messages.deactivateError"));
    }
  };

  const columns: ColumnsType<Dish> = [
    {
      title: t("dishes.table.columns.name"),
      dataIndex: "name",
      key: "name",
      render: (text, record) => (
        <Link
          to={`/dishes/${record.id}`}
          className="text-blue-500 hover:text-blue-700"
        >
          {text}
        </Link>
      ),
      sorter: (a, b) => a.name.localeCompare(b.name),
    },
    {
      title: t("dishes.table.columns.description"),
      dataIndex: "description",
      key: "description",
      ellipsis: true,
    },
    {
      title: t("dishes.table.columns.price"),
      dataIndex: "price",
      key: "price",
      render: (price) => `${price}`,
      sorter: (a, b) => a.price - b.price,
    },
    {
      title: t("dishes.table.columns.availability"),
      dataIndex: "available",
      key: "available",
      render: (available) => (
        <Tag color={available ? "green" : "red"}>
          {available ? t("dishes.status.available") : t("dishes.status.unavailable")}
        </Tag>
      ),
      sorter: (a, b) => Number(a.available) - Number(b.available),
    },
    {
      title: t("dishes.table.columns.images"),
      dataIndex: "gallery",
      key: "gallery",
      render: (gallery) => (
        <div className="flex space-x-1">
          {gallery?.slice(0, 3).map((img: { url: string }, index: number) => (
            <Image
              key={index}
              src={`${API_BASE_URL}${img.url}`}
              width={40}
              height={40}
              className="rounded"
              preview={false}
            />
          ))}
          {gallery?.length > 3 && (
            <Tag className="flex items-center">+{gallery.length - 3}</Tag>
          )}
        </div>
      ),
    },
    {
      title: t("dishes.table.columns.actions"),
      key: "actions",
      render: (_, record) => (
        <Space size="middle">
          <Button
            type="primary"
            icon={<EyeOutlined />}
            onClick={() => window.open(`/dishes/${record.id}`, "_self")}
            className="bg-blue-500 hover:bg-blue-600"
          />
          <Button
            type="primary"
            icon={<EditOutlined />}
            onClick={() => handleEditClick(record)}
            className="bg-yellow-500 hover:bg-yellow-600"
          />
          {record.available ? (
            <Button
              type="primary"
              onClick={() => handleDeactivateDish(record.id)}
              className="bg-orange-500 hover:bg-orange-600"
            >
              {t("dishes.actions.deactivate")}
            </Button>
          ) : (
            <Button
              type="primary"
              onClick={() => handleActivateDish(record.id)}
              className="bg-green-500 hover:bg-green-600"
            >
              {t("dishes.actions.activate")}
            </Button>
          )}
          <Button
            danger
            type="primary"
            icon={<DeleteOutlined />}
            onClick={() => handleDeleteClick(record.id)}
          />
        </Space>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-800">
          {t("dishes.title")}
        </h1>
        <Button
          type="primary"
          icon={<PlusOutlined />}
          onClick={() => setShowAddForm(true)}
          className="bg-blue-500 hover:bg-blue-600"
        >
          {t("dishes.addButton")}
        </Button>
      </div>

      <Card className="shadow-md">
        <Table
          columns={columns}
          dataSource={dishes}
          rowKey="id"
          pagination={{ pageSize: 10 }}
          scroll={{ x: true }}
          className="rounded-lg overflow-hidden"
        />
      </Card>

      <div className="mt-8">
        <h2 className="text-xl font-semibold mb-4">
          {t("dishes.galleryView")}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {dishes.map((dish) => (
            <DishCard
              key={dish.id}
              dish={dish}
              onEdit={handleEditClick}
              onDelete={handleDeleteClick}
              onDishUpdate={fetchDishes}
              t={t}
            />
          ))}
        </div>
      </div>

      {showAddForm && (
        <AddDishForm
          onClose={() => setShowAddForm(false)}
          onAddDish={handleAddDish}
        />
      )}

      <Modal
        title={t("dishes.editModalTitle")}
        open={showEditForm && dishToEdit !== null}
        onCancel={() => setShowEditForm(false)}
        footer={null}
        width={800}
        style={{ top: "10px" }}
      >
        {dishToEdit && (
          <EditDishForm
            dish={dishToEdit}
            onClose={() => setShowEditForm(false)}
            onUpdate={(id, data) => handleUpdateDish(id, data)}
          />
        )}
      </Modal>
    </div>
  );
};

const DishCard = ({
  dish,
  onEdit,
  onDelete,
  onDishUpdate,
  t,
}: {
  dish: Dish;
  onEdit: (dish: Dish) => void;
  onDelete: (id: string) => void;
  onDishUpdate: () => void;
  t: any;
}) => {
  const handleActivateDish = async () => {
    try {
      await activateDish(dish.id);
      onDishUpdate();
      message.success(t("dishes.messages.activateSuccess"));
    } catch (err) {
      console.error("Failed to activate dish:", err);
      message.error(t("dishes.messages.activateError"));
    }
  };

  const handleDeactivateDish = async () => {
    try {
      await deactivateDish(dish.id);
      onDishUpdate();
      message.success(t("dishes.messages.deactivateSuccess"));
    } catch (err) {
      console.error("Failed to deactivate dish:", err);
      message.error(t("dishes.messages.deactivateError"));
    }
  };
  const carouselRef = useRef<any>(null);
  const [categories, setCategories] = useState<any[]>([]);
  const [categoryTypes, setCategoryTypes] = useState<any[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const [loadingCategories, setLoadingCategories] = useState(false);
  const [dishCategories, setDishCategories] = useState<any[]>([]);
  const [loadingDishCategories, setLoadingDishCategories] = useState(false);

  useEffect(() => {
    const fetchCategoryTypes = async () => {
      try {
        const types = await getCategoryTypes();
        setCategoryTypes(types);
      } catch (error) {
        console.error('Error fetching category types:', error);
      }
    };

    fetchCategoryTypes();
  }, []);

  // Fetch dish categories using getCategory
  useEffect(() => {
        
    const fetchDishCategories = async () => {
      setLoadingDishCategories(true);
      try {
        const categoryData = await getDishById(dish.id);
        
        setDishCategories(categoryData.categories || []);
      } catch (error) {
        console.error('Error fetching dish categories:', error);
        setDishCategories([]);
      } finally {
        setLoadingDishCategories(false);
      }
    };

    fetchDishCategories();
  }, [dish.id]);

  const fetchCategories = async (type?: string) => {
    setLoadingCategories(true);
    try {
      const data = await getCategories(1, 100, 'nameEn', 'asc', '', type);
      
      setCategories(data || []);
    } catch (error) {
      console.error('Error fetching categories:', error);
    } finally {
      setLoadingCategories(false);
    }
  };

  const handleAddCategory = async () => {
    if (!selectedCategory) return;
    try {
      await addDishCategory(dish.id, selectedCategory);
      // Refresh dish categories after adding
      const updatedCategories = await getDishById(dish.id);
      setDishCategories(updatedCategories.categories || []);
      setSelectedCategory("");
      message.success(t('dishes.messages.categoryAdded'));
      // Optionally refresh the entire dish list
      onDishUpdate();
    } catch (error) {
      message.error(t('dishes.messages.categoryAddError'));
    }
  };

  const handleRemoveCategory = async (categoryId: string) => {
    try {
      await removeDishCategory(dish.id, categoryId);
      // Refresh dish categories after removing
      const updatedCategories = await getDishById(dish.id);
      setDishCategories(updatedCategories.categories || []);
      message.success(t('dishes.messages.categoryRemoved'));
      // Optionally refresh the entire dish list
      onDishUpdate();
    } catch (error) {
      message.error(t('dishes.messages.categoryRemoveError'));
    }
  };

  const handlePrev = () => {
    carouselRef.current?.prev();
  };

  const handleNext = () => {
    carouselRef.current?.next();
  };
  
  return (
    <Card
      hoverable
      cover={
        <div className="relative">
          {dish.gallery && dish.gallery.length > 0 ? (
            <>
              <Carousel
                ref={carouselRef}
                autoplay
                dots={true}
                dotPosition="bottom"
                className="h-48"
              >
                {dish.gallery.map((img, index) => (
                  <div
                    key={index}
                    className="h-48 flex items-center justify-center"
                  >
                    <Image
                      src={`${API_BASE_URL}${img.url}`}
                      alt={dish.name}
                      height={200}
                      width="100%"
                      className="object-cover w-full h-full"
                      preview={{
                        mask: <EyeOutlined style={{ color: "white" }} />,
                        maskClassName: "flex items-center justify-center",
                      }}
                    />
                  </div>
                ))}
              </Carousel>

              {dish.gallery.length > 1 && (
                <>
                  <Button
                    type="text"
                    icon={<LeftOutlined />}
                    onClick={handlePrev}
                    className="absolute left-2 top-1/2 transform -translate-y-1/2 z-10 bg-white bg-opacity-50 hover:bg-opacity-100"
                    shape="circle"
                  />
                  <Button
                    type="text"
                    icon={<RightOutlined />}
                    onClick={handleNext}
                    className="absolute right-2 top-1/2 transform -translate-y-1/2 z-10 bg-white bg-opacity-50 hover:bg-opacity-100"
                    shape="circle"
                  />
                </>
              )}
            </>
          ) : (
            <div className="h-48 bg-gray-200 flex items-center justify-center">
              <span className="text-gray-500">{t("dishes.card.noImage")}</span>
            </div>
          )}
        </div>
      }
      actions={[
        <EyeOutlined
          key="view"
          onClick={() => window.open(`/dishes/${dish.id}`, "_self")}
        />,
        <EditOutlined key="edit" onClick={() => onEdit(dish)} />,
        dish.available ? (
          <Button
            key="deactivate"
            type="primary"
            onClick={handleDeactivateDish}
            className="bg-orange-500 hover:bg-orange-600"
            size="small"
          >
            {t("dishes.actions.deactivate")}
          </Button>
        ) : (
          <Button
            key="activate"
            type="primary"
            onClick={handleActivateDish}
            className="bg-green-500 hover:bg-green-600"
            size="small"
          >
            {t("dishes.actions.activate")}
          </Button>
        ),
        <DeleteOutlined key="delete" onClick={() => onDelete(dish.id)} />,
      ]}
      className="rounded-lg overflow-hidden shadow flex flex-col h-full"
      bodyStyle={{ flex: 1 }}
    >
      <Card.Meta
        title={
          <div className="flex justify-between items-center">
            <span>{dish.name}</span>
            <Tag color={dish.available ? "green" : "red"}>
              {dish.available ? t("dishes.status.available") : t("dishes.status.unavailable")}
            </Tag>
          </div>
        }
        description={
          <div className="flex flex-col h-full">
            <p className="text-gray-600 line-clamp-2 mb-2">
              {dish.description}
            </p>
            {/* Categories section */}
            <div className="mb-4">
              <h4 className="font-medium mb-2">{t('dishes.categories')}</h4>
              {loadingDishCategories ? (
                <div className="flex justify-center mb-3">
                  <Spin size="small" />
                </div>
              ) : dishCategories.length > 0 ? (
                <div className="flex flex-wrap gap-2 mb-3">
                  {dishCategories.map(category => (
                    <Tag 
                      key={category.id} 
                      closable 
                      onClose={() => handleRemoveCategory(category.id)}
                    >
                      {category.nameEn || category.name}
                    </Tag>
                  ))}
                </div>
              ) : (
                <p className="text-gray-500 text-sm mb-3">{t('dishes.noCategories')}</p>
              )}
              
              <div className="flex flex-col gap-2">
                <Select
                  placeholder={t('dishes.selectCategoryType')}
                  className="flex-1"
                  onChange={(value) => fetchCategories(value)}
                  options={categoryTypes.map(type => ({
                    value: type.value,
                    label: type.label
                  }))}
                />
                
                <Select
                  placeholder={t('dishes.selectCategory')}
                  className="flex-1"
                  loading={loadingCategories}
                  disabled={!categories.length}
                  value={selectedCategory}
                  onChange={setSelectedCategory}
                  options={categories.map(cat => ({
                    value: cat.id,
                    label: cat.nameEn
                  })
                )}
                />
                
                <Button 
                  type="primary" 
                  onClick={handleAddCategory}
                  disabled={!selectedCategory}
                  size="small"
                >
                  {t('dishes.addCategory')}
                </Button>
              </div>
            </div>
            <div className="mt-auto">
              <p className="text-lg font-bold">${dish.price}</p>
              {dish.gallery && dish.gallery.length > 1 && (
                <div className="flex justify-center mt-2 space-x-1">
                  {dish.gallery.map((_, index) => (
                    <Button
                      key={index}
                      type="text"
                      size="small"
                      onClick={() => carouselRef.current?.goTo(index)}
                      className={`h-2 w-2 p-0 min-w-0 rounded-full ${
                        carouselRef.current?.innerSlider.state.currentSlide ===
                        index
                          ? "bg-blue-500"
                          : "bg-gray-300"
                      }`}
                    />
                  ))}
                </div>
              )}
            </div>
          </div>
        }
      />
    </Card>
  );
};

export default Dishes;
