import { useEffect, useState, useMemo } from "react";
import { useParams, Link } from "react-router-dom";
import {
  getDishById,
  addDishImages,
  deleteDishImage,
  getAllergen,
  addDishAllergen,
  removeDishAllergen
} from "../../services/disheService";
import { Dish } from "../../types/dishes";
import API_BASE_URL from "../../config/apiConfig";
import {
  Button,
  Card,
  Table,
  Input,
  Select,
  Checkbox,
  Modal,
  Upload,
  Image,
  Spin,
  Tag,
  Divider,
  Space,
  Typography,
  Row,
  Col,
  message,
  InputNumber,
  Form,
  Tabs,
} from "antd";
import {
  UploadOutlined,
  DeleteOutlined,
  EditOutlined,
  ArrowLeftOutlined,
  PlusOutlined,
  ExclamationCircleFilled,
} from "@ant-design/icons";
import {
  getAllIngredients,
  getDishIngredients,
  addDishIngredient,
  updateDishIngredient,
  removeDishIngredient,
  createIngredient,
  deleteIngredient,
} from "../../services/ingredientService";
import { Ingredient, DishIngredient, Allergen, DishAllergen } from "../../types/dishes";
import { useTranslation } from "react-i18next";

const { Title, Text, Paragraph } = Typography;
const { Option } = Select;
const { confirm } = Modal;
const { Item } = Form;
const { TabPane } = Tabs;

const DishDetail = () => {
  const { t } = useTranslation();
  const { id: dishId } = useParams<{ id: string }>();
  const [form] = Form.useForm();
  const [dish, setDish] = useState<Dish | null>(null);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);

  const [allIngredients, setAllIngredients] = useState<Ingredient[]>([]);
  const [dishIngredients, setDishIngredients] = useState<DishIngredient[]>([]);
  const [newIngredient, setNewIngredient] = useState({
    ingredientId: "",
    isSupplement: false,
    price: 0,
  });

  const [editingIngredient, setEditingIngredient] =
    useState<DishIngredient | null>(null);
  const [showCreateIngredientModal, setShowCreateIngredientModal] = useState(false);

  // Allergen state
  const [allAllergens, setAllAllergens] = useState<Allergen[]>([]);
  const [dishAllergens, setDishAllergens] = useState<DishAllergen[]>([]);
  const [newAllergen, setNewAllergen] = useState({
    allergenId: "",
    specification: "",
  });

  // Search, filter and sort state
  const [searchTerm, setSearchTerm] = useState("");
  const [filterValue, setFilterValue] = useState("all");
  const [sortConfig, setSortConfig] = useState({
    key: "nameEn",
    direction: "asc",
  });
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 10,
    total: 0,
  });

  // Fetch all data
  useEffect(() => {
    const fetchData = async () => {
      try {
        if (dishId) {
          const [dishData, dishIngs, ingredients, allergens] = await Promise.all([
            getDishById(dishId),
            getDishIngredients(dishId),
            getAllIngredients(),
            getAllergen(),
          ]);

          setDish(dishData);
          setDishIngredients(dishIngs);
          setAllIngredients(ingredients.data);
          setAllAllergens(allergens);
          setPagination((prev) => ({ ...prev, total: ingredients.data.length }));
        }
      } catch (err) {
        console.error("Failed to fetch data:", err);
        message.error(t('dish.detail.messages.fetchError'));
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [dishId]);

  // Filter, sort and paginate ingredients
  const filteredIngredients = useMemo(() => {
    let result = [...allIngredients];

    // Apply search
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      result = result.filter(
        (ing) =>
          ing.nameEn.toLowerCase().includes(term) ||
          ing.nameFr.toLowerCase().includes(term)
      );
    }

    // Apply filter
    if (filterValue === "supplements") {
      result = result.filter((ing) =>
        dishIngredients.some(
          (di) => di.ingredient?.id === ing.id && di.isSupplement
        )
      );
    } else if (filterValue === "regular") {
      result = result.filter((ing) =>
        dishIngredients.some(
          (di) => di.ingredient?.id === ing.id && !di.isSupplement
        )
      );
    }

    // Apply sorting
    return result.sort((a, b) => {
      const aValue = a[sortConfig.key as keyof Ingredient] ?? "";
      const bValue = b[sortConfig.key as keyof Ingredient] ?? "";

      if (aValue < bValue) {
        return sortConfig.direction === "asc" ? -1 : 1;
      }
      if (aValue > bValue) {
        return sortConfig.direction === "asc" ? 1 : -1;
      }
      return 0;
    });
  }, [allIngredients, searchTerm, filterValue, sortConfig, dishIngredients]);

  // Paginated ingredients
  const paginatedIngredients = useMemo(() => {
    const startIndex = (pagination.page - 1) * pagination.limit;
    return filteredIngredients.slice(startIndex, startIndex + pagination.limit);
  }, [filteredIngredients, pagination.page, pagination.limit]);

  // Update pagination total when filtered results change
  useEffect(() => {
    setPagination((prev) =>({
      ...prev,
      total: filteredIngredients.length,
      page: Math.min(
        prev.page,
        Math.ceil(filteredIngredients.length / prev.limit) || 1
      ),
    }));
  }, [filteredIngredients]);

  const handleFileChange = (info: any) => {
    if (info.fileList) {
      setSelectedFiles(info.fileList.map((file: any) => file.originFileObj));
    }
  };

  const handleUpload = async () => {
    if (!dishId || !selectedFiles.length) return;

    setUploading(true);
    try {
      const formData = new FormData();
      selectedFiles.forEach((file) => {
        formData.append("gallery[]", file);
      });

      const updatedDish = await addDishImages(dishId, formData);
      setDish(updatedDish);
      setSelectedFiles([]);
      message.success(t('dish.detail.messages.imageUploadSuccess'));
    } catch (err) {
      console.error("Failed to upload images:", err);
      message.error(t('dish.detail.messages.imageUploadError'));
    } finally {
      setUploading(false);
    }
  };

  const handleAddIngredient = async () => {
    if (!dishId || !newIngredient.ingredientId) return;

    try {
      const addedIngredient = await addDishIngredient(
        dishId,
        newIngredient.ingredientId,
        {
          isSupplement: newIngredient.isSupplement,
          price: newIngredient.isSupplement ? newIngredient.price : 0,
        }
      );

      setDishIngredients([...dishIngredients, addedIngredient]);
      setNewIngredient({
        ingredientId: "",
        isSupplement: false,
        price: 0,
      });
      const ingredients = await getAllIngredients();
      setAllIngredients(ingredients.data);
      message.success(t('dish.detail.messages.ingredientAddSuccess'));
    } catch (err) {
      console.error("Failed to add ingredient:", err);
      message.error(t('dish.detail.messages.ingredientAddError'));
    }
  };

  const handleUpdateIngredient = async () => {

    if (!dishId || !editingIngredient?.ingredientId) return;

    try {
      const updated = await updateDishIngredient(
        dishId,
        editingIngredient.ingredientId,
        {
          price: editingIngredient.price,
          isSupplement: editingIngredient.isSupplement,
          available: editingIngredient.available,
        }
      );

      setDishIngredients(
        dishIngredients.map((ing) =>
          ing.ingredient?.id === updated.ingredient?.id ? updated : ing
        )
      );
      setEditingIngredient(null);
      message.success(t('dish.detail.messages.ingredientUpdateSuccess'));
    } catch (err) {
      console.error("Failed to update ingredient:", err);
      message.error(t('dish.detail.messages.ingredientUpdateError'));
    }
  };

  const handleRemoveIngredient = async (ingredientId: string) => {

    if (!dishId) return;

    confirm({
      title: t('dish.detail.confirm.removeIngredient.title'),
      icon: <ExclamationCircleFilled />,
      content: t('dish.detail.confirm.removeIngredient.content'),
      okText: t('dish.detail.confirm.removeIngredient.okText'),
      okType: "danger",
      cancelText: t('dish.detail.confirm.removeIngredient.cancelText'),
      onOk: async () => {
        try {
          await removeDishIngredient(dishId, ingredientId);
          setDishIngredients(
            dishIngredients.filter((ing) => ing.ingredient?.id !== ingredientId)
          );
          const ingredients = await getAllIngredients();
          setAllIngredients(ingredients.data);
          message.success(t('dish.detail.messages.ingredientRemoveSuccess'));
        } catch (err) {
          console.error("Failed to remove ingredient:", err);
          message.error(t('dish.detail.messages.ingredientRemoveError'));
        }
      },
    });
  };

  const handleDeleteImage = async (mediaId: string) => {
    if (!dishId || !dish) return;

    confirm({
      title: t('dish.detail.modals.delete.image.title'),
      icon: <ExclamationCircleFilled />,
      content: t('dish.detail.modals.delete.image.content'),
      okText: t('dish.detail.modals.delete.image.okText'),
      okType: "danger",
      cancelText: t('dish.detail.modals.delete.image.cancelText'),
      onOk: async () => {
        try {
          await deleteDishImage(dishId, mediaId);
          setDish({
            ...dish,
            gallery: dish.gallery.filter((img) => img.id !== mediaId),
          });
          message.success(t('dish.detail.messages.imageDeleteSuccess'));
        } catch (err) {
          console.error("Failed to delete image:", err);
          message.error(t('dish.detail.messages.imageDeleteError'));
        }
      },
    });
  };

  const handleCreateIngredient = async (values: { nameEn: string; nameFr: string }) => {
    try {
      const newIngredient = await createIngredient(values);
      setAllIngredients([...allIngredients, newIngredient]);
      setShowCreateIngredientModal(false);
      form.resetFields();
      message.success(t('dish.detail.messages.ingredientCreateSuccess'));
    } catch (err) {
      console.error("Failed to create ingredient:", err);
      message.error("Failed to create ingredient");
    }
  };

  const handleDeleteIngredient = async (ingredientId: string) => {
    confirm({
      title: t('dish.detail.confirm.deleteIngredient.title'),
      icon: <ExclamationCircleFilled />,
      content: t('dish.detail.confirm.deleteIngredient.content'),
      okText: t('dish.detail.confirm.deleteIngredient.okText'),
      okType: "danger",
      cancelText: t('dish.detail.confirm.deleteIngredient.cancelText'),
      onOk: async () => {
        try {
          await deleteIngredient(ingredientId);
          setAllIngredients(allIngredients.filter(ing => ing.id !== ingredientId));
          message.success(t('dish.detail.messages.ingredientDeleteSuccess'));
        } catch (err) {
          console.error("Failed to delete ingredient:", err);
          message.error("Failed to delete ingredient");
        }
      },
    });
  };

  // Allergen handlers
  const handleAddAllergen = async () => {
    if (!dishId || !newAllergen.allergenId) return;

    try {
      const addedAllergen = await addDishAllergen(
        dishId,
        newAllergen.allergenId,
        newAllergen.specification || undefined
      );

      setDishAllergens([...dishAllergens, addedAllergen]);
      setNewAllergen({
        allergenId: "",
        specification: "",
      });
      message.success(t('dish.detail.messages.allergenAddSuccess'));
    } catch (err) {
      console.error("Failed to add allergen:", err);
      message.error(t('dish.detail.messages.allergenAddError'));
    }
  };

  const handleRemoveAllergen = async (allergenId: string) => {
    if (!dishId) return;

    confirm({
      title: t('dish.detail.confirm.removeAllergen.title'),
      icon: <ExclamationCircleFilled />,
      content: t('dish.detail.confirm.removeAllergen.content'),
      okText: t('dish.detail.confirm.removeAllergen.okText'),
      okType: "danger",
      cancelText: t('dish.detail.confirm.removeAllergen.cancelText'),
      onOk: async () => {
        try {
          await removeDishAllergen(dishId, allergenId);
          setDishAllergens(
            dishAllergens.filter((da) => da.allergenId !== allergenId)
          );
          message.success(t('dish.detail.messages.allergenRemoveSuccess'));
        } catch (err) {
          console.error("Failed to remove allergen:", err);
          message.error(t('dish.detail.messages.allergenRemoveError'));
        }
      },
    });
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Spin size="large" />
      </div>
    );
  }

  if (!dish) {
    return (
      <div className="flex justify-center items-center h-64">
        <Text type="danger">{t('dish.detail.notFound')}</Text>
      </div>
    );
  }

  const ingredientColumns = [
    {
      title: t('dish.detail.labels.ingredientColumns.nameEn'),
      dataIndex: "nameEn",
      key: "nameEn",
    },
    {
      title: t('dish.detail.labels.ingredientColumns.nameFr'),
      dataIndex: "nameFr",
      key: "nameFr",
    },
    {
      title: t('dish.detail.labels.ingredientColumns.actions'),
      key: "actions",
      render: (_: any, record: Ingredient) => (
        <Space>
          <Button
            type="link"
            onClick={() =>
              setNewIngredient({
                ...newIngredient,
                ingredientId: record.id,
              })
            }
          >
            {t('dish.detail.labels.ingredientColumns.select')}
          </Button>
          <Button
            type="text"
            danger
            icon={<DeleteOutlined />}
            onClick={() => handleDeleteIngredient(record.id)}
          />
        </Space>
      ),
    },
  ];

  const dishIngredientColumns = [
    {
      title: t('dish.detail.table.columns.ingredientEn'),
      key: "ingredientEn",
      render: (record: DishIngredient) => record.ingredientNameEn

    },
    {
      title: t('dish.detail.table.columns.ingredientFr'),
      key: "ingredientFr",
      render: (record: DishIngredient) => record.ingredientNameFr

    },
    {
      title: t('dish.detail.table.columns.supplement'),
      key: "isSupplement",
      render: (record: DishIngredient) =>
        record.isSupplement ? (
          <Tag color="green">{t('dish.detail.labels.supplementYes')}</Tag>
        ) : (
          <Tag color="blue">{t('dish.detail.labels.supplementNo')}</Tag>
        ),
    },
    {
      title: t('dish.detail.table.columns.price'),
      dataIndex: "price",
      key: "price",
      render: (price: number) => `${price}`,
    },
    {
      title: t('dish.detail.table.columns.available'),
      key: "available",
      render: (record: DishIngredient) => (
        <Checkbox checked={record.available} disabled />
      ),
    },
    {
      title: t('dish.detail.table.columns.actions'),
      key: "actions",
      render: (_: any, record: DishIngredient) => (
        <Space>
          <Button
            type="text"
            icon={<EditOutlined />}
            onClick={() => setEditingIngredient(record)}
          />
          <Button
            type="text"
            danger
            icon={<DeleteOutlined />}
            onClick={() => record?.ingredientId && handleRemoveIngredient(record.ingredientId)}
          />
        </Space>
      ),
    },
  ];

  return (
    <div className="container mx-auto px-4 py-8">
      <Link to="/dishes">
        <Button type="text" icon={<ArrowLeftOutlined />}>
          {t('dish.detail.backButton')}
        </Button>
      </Link>

      <Tabs defaultActiveKey="details" className="mb-6">
        <TabPane tab={t('dish.detail.tabs.dishDetails')} key="details">
          <Card className="mb-6 mt-4" title={<Title level={2}>{dish.name}</Title>}>
            <Paragraph>{dish.description}</Paragraph>

            <Divider orientation="left">{t('dish.detail.sections.details')}</Divider>
            <Title level={4}>Dish Information</Title>
            <Paragraph>{dish.description}</Paragraph>
            <Row gutter={16}>
              <Col span={8}>
                <Text strong>Available:</Text> {dish.available ? t('dish.detail.labels.supplementYes') : t('dish.detail.labels.supplementNo')}
              </Col>
              <Col span={8}>
                <Text strong>Rating:</Text> {dish.averageRating || 'No rating'}
              </Col>
            </Row>
            <Row gutter={16}>
              <Col span={8}>
                <Text strong>Price:</Text> ${dish.price}
              </Col>
            </Row>

            <Divider orientation="left">{t('dish.detail.sections.images')}</Divider>
            <Space direction="vertical" size="middle" style={{ width: "100%" }}>
              <Upload
                multiple
                beforeUpload={() => false}
                fileList={selectedFiles.map((file, index) => ({
                  uid: `${index}`,
                  name: file.name,
                  status: "done",
                }))}
                onChange={handleFileChange}
              >
                <Button icon={<UploadOutlined />}>{t('dish.detail.labels.selectImages')}</Button>
              </Upload>

              {selectedFiles.length > 0 && (
                <Space>
                  <Button
                    type="primary"
                    onClick={handleUpload}
                    loading={uploading}
                    icon={<UploadOutlined />}
                  >
                    {t('dish.detail.labels.uploadImages', { count: selectedFiles.length })}
                  </Button>
                  <Button onClick={() => setSelectedFiles([])}>{t('common.cancel')}</Button>
                </Space>
              )}

              {dish.gallery?.length > 0 ? (
                <Image.PreviewGroup>
                  <Row gutter={[16, 16]}>
                    {dish.gallery.map((image) => (
                      <Col key={image.id} xs={12} sm={8} md={6} lg={4}>
                        <div className="relative">
                          <Image
                            src={`${API_BASE_URL}${image.url}`}
                            alt={`${dish.name}`}
                            className="rounded"
                          />
                          <Button
                            danger
                            type="text"
                            icon={<DeleteOutlined />}
                            className="absolute top-2 right-2"
                            onClick={() => handleDeleteImage(image.id)}
                          />
                        </div>
                      </Col>
                    ))}
                  </Row>
                </Image.PreviewGroup>
              ) : (
                <Text type="secondary">{t('dish.detail.labels.noImages')}</Text>
              )}
            </Space>
          </Card>
        </TabPane>

        <TabPane tab={t('dish.detail.tabs.ingredients')} key="ingredients">
          <Space direction="vertical" size="middle" style={{ width: "100%" }}>
            <Card title={t('dish.detail.cards.addIngredient.title')} type="inner">
              <Space size="middle" align="start">
                <Select
                  placeholder={t('dish.detail.cards.addIngredient.placeholders.selectIngredient')}
                  style={{ width: 200 }}
                  value={newIngredient.ingredientId || undefined}
                  onChange={(value) =>
                    setNewIngredient({
                      ...newIngredient,
                      ingredientId: value,
                    })
                  }
                >
                  {allIngredients.map((ing) => (
                    <Option key={ing.id} value={ing.id}>
                      {ing.nameEn} - {ing.nameFr}
                    </Option>
                  ))}
                </Select>

                <Checkbox
                  checked={newIngredient.isSupplement}
                  onChange={(e) =>
                    setNewIngredient({
                      ...newIngredient,
                      isSupplement: e.target.checked,
                      price: e.target.checked ? newIngredient.price : 0,
                    })
                  }
                >
                  {t('dish.detail.cards.addIngredient.labels.isSupplement')}
                </Checkbox>

                {newIngredient.isSupplement && (
                  <InputNumber
                    min={0}
                    step={0.01}
                    value={newIngredient.price}
                    onChange={(value) =>
                      setNewIngredient({
                        ...newIngredient,
                        price: value || 0,
                      })
                    }
                    placeholder={t('dish.detail.cards.addIngredient.placeholders.price')}
                  />
                )}

                <Button
                  type="primary"
                  onClick={handleAddIngredient}
                  disabled={!newIngredient.ingredientId}
                  icon={<PlusOutlined />}
                >
                  {t('dish.detail.cards.addIngredient.buttons.add')}
                </Button>

                <Button
                  type="dashed"
                  onClick={() => setShowCreateIngredientModal(true)}
                  icon={<PlusOutlined />}
                >
                  {t('dish.detail.cards.addIngredient.buttons.createNew')}
                </Button>
              </Space>
            </Card>

            <Card title={t('dish.detail.cards.availableIngredients.title')} type="inner">
              <Space direction="vertical" size="middle" style={{ width: "100%" }}>
                <Space>
                  <Input
                    placeholder={t('dish.detail.cards.availableIngredients.placeholders.searchIngredients')}
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    style={{ width: 200 }}
                  />
                  <Select
                    value={filterValue}
                    onChange={(value) => setFilterValue(value)}
                    style={{ width: 180 }}
                  >
                    <Option value="all">{t('dish.detail.cards.availableIngredients.options.allIngredients')}</Option>
                    <Option value="supplements">{t('dish.detail.cards.availableIngredients.options.supplementsOnly')}</Option>
                    <Option value="regular">{t('dish.detail.cards.availableIngredients.options.regularOnly')}</Option>
                  </Select>
                  <Select
                    value={`${sortConfig.key}:${sortConfig.direction}`}
                    onChange={(value) => {
                      const [key, direction] = value.split(":");
                      setSortConfig({
                        key,
                        direction: direction as "asc" | "desc",
                      });
                    }}
                    style={{ width: 180 }}
                  >
                    <Option value="nameEn:asc">{t('dish.detail.cards.availableIngredients.sortOptions.nameAsc')}</Option>
                    <Option value="nameEn:desc">{t('dish.detail.cards.availableIngredients.sortOptions.nameDesc')}</Option>
                    <Option value="createdAt:desc">{t('dish.detail.cards.availableIngredients.sortOptions.newestFirst')}</Option>
                    <Option value="createdAt:asc">{t('dish.detail.cards.availableIngredients.sortOptions.oldestFirst')}</Option>
                  </Select>
                </Space>

                <Table
                  columns={ingredientColumns}
                  dataSource={paginatedIngredients}
                  rowKey="id"
                  pagination={{
                    current: pagination.page,
                    pageSize: pagination.limit,
                    total: pagination.total,
                    onChange: (page) =>
                      setPagination((prev) => ({ ...prev, page })),
                    showSizeChanger: false,
                  }}
                  size="small"
                />
              </Space>
            </Card>

            <Card title={t('dish.detail.cards.dishIngredients.title')} type="inner">
              <Table
                columns={dishIngredientColumns}
                dataSource={dishIngredients}
                rowKey={(record) => `${record.id}`}
                pagination={false}
              />
            </Card>
          </Space>
        </TabPane>

        <TabPane tab={t('dish.detail.tabs.allergens')} key="allergens">
          <Space direction="vertical" size="middle" style={{ width: "100%" }}>
            <Card title={t('dish.detail.cards.addAllergen.title')} type="inner">
              <Space size="middle" align="start">
                <Select
                  placeholder={t('dish.detail.cards.addAllergen.placeholders.selectAllergen')}
                  style={{ width: 200 }}
                  value={newAllergen.allergenId || undefined}
                  onChange={(value) =>
                    setNewAllergen({
                      ...newAllergen,
                      allergenId: value,
                    })
                  }
                >
                  {allAllergens.map((allergen) => (
                    <Option key={allergen.id} value={allergen.id}>
                      {allergen.nameEn} - {allergen.nameFr}
                    </Option>
                  ))}
                </Select>

                {allAllergens.find(a => a.id === newAllergen.allergenId)?.requiresSpecification && (
                  <Input
                    placeholder={t('dish.detail.cards.addAllergen.placeholders.specification')}
                    value={newAllergen.specification}
                    onChange={(e) =>
                      setNewAllergen({
                        ...newAllergen,
                        specification: e.target.value,
                      })
                    }
                    style={{ width: 200 }}
                  />
                )}

                <Button
                  type="primary"
                  onClick={handleAddAllergen}
                  disabled={!newAllergen.allergenId}
                  icon={<PlusOutlined />}
                >
                  {t('dish.detail.cards.addAllergen.buttons.addAllergen')}
                </Button>
              </Space>
            </Card>

            <Card title={t('dish.detail.cards.dishAllergens.title')} type="inner">
              <Table
                columns={[
                  {
                    title: t('dish.detail.table.columns.allergenEn'),
                    key: "allergenEn",
                    render: (record: DishAllergen) => {
                      const allergen = allAllergens.find(a => a.id === record.allergenId);
                      return allergen?.nameEn || record.allergenId;
                    }
                  },
                  {
                    title: t('dish.detail.table.columns.allergenFr'),
                    key: "allergenFr",
                    render: (record: DishAllergen) => {
                      const allergen = allAllergens.find(a => a.id === record.allergenId);
                      return allergen?.nameFr || record.allergenId;
                    }
                  },
                  {
                    title: t('dish.detail.table.columns.specification'),
                    key: "specification",
                    render: (record: DishAllergen) => record.specification || "-",
                  },
                  {
                    title: t('dish.detail.table.columns.actions'),
                    key: "actions",
                    render: (_: any, record: DishAllergen) => (
                      <Button
                        type="text"
                        danger
                        icon={<DeleteOutlined />}
                        onClick={() => handleRemoveAllergen(record.allergenId)}
                      />
                    ),
                  },
                ]}
                dataSource={dishAllergens}
                rowKey={(record) => `${record.allergenId}`}
                pagination={false}
              />
            </Card>
          </Space>
        </TabPane>
      </Tabs>

      <Modal
        title={t('dish.detail.modals.editIngredient.title')}
        open={!!editingIngredient}
        onCancel={() => setEditingIngredient(null)}
        footer={[
          <Button key="cancel" onClick={() => setEditingIngredient(null)}>
            {t('dish.detail.modals.editIngredient.buttons.cancel')}
          </Button>,
          <Button key="save" type="primary" onClick={handleUpdateIngredient}>
            {t('dish.detail.modals.editIngredient.buttons.save')}
          </Button>,
        ]}
      >
        {editingIngredient && (
          <Space direction="vertical" style={{ width: "100%" }}>
            <Text strong>{t('dish.detail.form.ingredientLabel')}</Text>
            <Text>
              {editingIngredient.ingredient?.nameEn}
            </Text>

            <Checkbox
              checked={editingIngredient.isSupplement}
              onChange={(e) =>
                setEditingIngredient({
                  ...editingIngredient,
                  isSupplement: e.target.checked,
                  price: e.target.checked ? editingIngredient.price : 0,
                })
              }
            >
              {t('dish.detail.cards.addIngredient.labels.isSupplement')}
            </Checkbox>

            {editingIngredient.isSupplement && (
              <>
                <Text strong>{t('dish.detail.form.priceLabel')}</Text>
                <InputNumber
                  min={0}
                  step={0.01}
                  value={editingIngredient.price}
                  onChange={(value) =>
                    setEditingIngredient({
                      ...editingIngredient,
                      price: value || 0,
                    })
                  }
                  style={{ width: "100%" }}
                />
              </>
            )}

            <Text strong>{t('dish.detail.form.availableLabel')}</Text>
            <Checkbox
              checked={editingIngredient.available}
              onChange={(e) =>
                setEditingIngredient({
                  ...editingIngredient,
                  available: e.target.checked,
                })
              }
            >
              {t('dish.detail.form.availableLabel')}
            </Checkbox>
          </Space>
        )}
      </Modal>

      <Modal
        title={t('dish.detail.modals.createIngredient.title')}
        open={showCreateIngredientModal}
        onCancel={() => {
          setShowCreateIngredientModal(false);
          form.resetFields();
        }}
        footer={[
          <Button
            key="cancel"
            onClick={() => {
              setShowCreateIngredientModal(false);
              form.resetFields();
            }}
          >
            {t('dish.detail.modals.createIngredient.buttons.cancel')}
          </Button>,
          <Button
            key="submit"
            type="primary"
            onClick={() => form.submit()}
          >
            {t('dish.detail.modals.createIngredient.buttons.create')}
          </Button>,
        ]}
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleCreateIngredient}
        >
          <Item
            name="nameEn"
            label={t('dish.detail.modals.createIngredient.fields.nameEn')}
            rules={[{ required: true, message: t('dish.detail.modals.createIngredient.fields.nameEnRequired') }]}
          >
            <Input />
          </Item>
          <Item
            name="nameFr"
            label={t('dish.detail.modals.createIngredient.fields.nameFr')}
            rules={[{ required: true, message: t('dish.detail.modals.createIngredient.fields.nameFrRequired') }]}
          >
            <Input />
          </Item>
        </Form>
      </Modal>
    </div>
  );
};

export default DishDetail;
