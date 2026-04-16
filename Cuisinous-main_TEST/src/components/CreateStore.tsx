import { useState, useEffect, useRef } from "react";
import {
  createFoodStore,
  getFoodStore,
  updateFoodStore,
  deleteFoodStore,
  updateFoodStoreImage,
} from "../services/storeService";
import { Location } from "../types/store";
import { API_BASE_URL } from "../config/apiConfig";
import {
  Button,
  Card,
  Col,
  Divider,
  Form,
  Input,
  InputNumber,
  Modal,
  Row,
  Spin,
  Upload,
  message,
  Descriptions,
  Space,
  Image,
  UploadFile,
} from "antd";
import {
  DeleteOutlined,
  EditOutlined,
  PlusOutlined,
  EnvironmentOutlined,
} from "@ant-design/icons";
import { useTranslation } from "react-i18next";

declare global {
  interface Window {
    google: {
      maps: typeof google.maps;
      mapsEvent: typeof google.maps.event;
    };
  }
}

interface Coordinates {
  lat: number;
  lng: number;
}

interface StoreFormValues {
  name: string;
  description?: string;
  location?: Partial<Location>;
}

const { TextArea } = Input;

const CreateStore = () => {
  const { t } = useTranslation();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [store, setStore] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isDeleting, setIsDeleting] = useState(false);
  const [form] = Form.useForm<StoreFormValues>();
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  const [mapLoaded, setMapLoaded] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState<Coordinates | null>(null);
  
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<google.maps.Map | null>(null);
  const marker = useRef<google.maps.Marker | null>(null);
  const autocompleteRef = useRef<google.maps.places.Autocomplete | null>(null);

  const loadGoogleMapsScript = (callback: () => void) => {
    if (window.google?.maps) {
      callback();
      return;
    }

    const script = document.createElement("script");
    script.src = `https://maps.googleapis.com/maps/api/js?key=AIzaSyDZmv9tvMdw3rHZRtUA4-_GTc2A02fXk_A&libraries=places`;
    script.async = true;
    script.defer = true;
    script.onload = callback;
    script.onerror = () => {
      message.error(t("map.loadError"));
    };
    document.head.appendChild(script);
  };

  const initializeMap = () => {
    if (!mapRef.current || !window.google.maps) return;

    const initialLocation = selectedLocation || { lat: 0, lng: 0 };
    
    mapInstance.current = new window.google.maps.Map(mapRef.current, {
      center: initialLocation,
      zoom: 2,
      minZoom: 2,
      maxZoom: 18,
      streetViewControl: false,
      fullscreenControl: false,
      mapTypeControl: true,
      gestureHandling: "cooperative"
    });

    if (selectedLocation) {
      marker.current = new window.google.maps.Marker({
        position: selectedLocation,
        map: mapInstance.current,
        draggable: true,
      });

      marker.current.addListener("dragend", (e: google.maps.MapMouseEvent) => {
        const newPosition = e.latLng?.toJSON();
        if (newPosition) {
          handleLocationChange(newPosition);
        }
      });
    }

    mapInstance.current.addListener("click", (e: google.maps.MapMouseEvent) => {
      const location = e.latLng?.toJSON();
      if (location) {
        handleLocationChange(location);
      }
    });

    initializeAutocomplete();
  };

  const initializeAutocomplete = () => {
    const addressInput = document.getElementById("address-search") as HTMLInputElement;
    if (!addressInput) return;

    autocompleteRef.current = new window.google.maps.places.Autocomplete(addressInput);
    autocompleteRef.current.addListener("place_changed", () => {
      const place = autocompleteRef.current?.getPlace();
      if (!place?.geometry?.location) return;

      const location = {
        lat: place.geometry.location.lat(),
        lng: place.geometry.location.lng(),
      };

      handleLocationChange(location, {
        street: place.address_components?.find(c => c.types.includes("route"))?.long_name,
        city: place.address_components?.find(c => c.types.includes("locality"))?.long_name,
        state: place.address_components?.find(c => c.types.includes("administrative_area_level_1"))?.long_name,
        zipCode: place.address_components?.find(c => c.types.includes("postal_code"))?.long_name,
        country: place.address_components?.find(c => c.types.includes("country"))?.long_name,
      });
    });
  };

  const handleLocationChange = (
    location: Coordinates,
    addressDetails?: Partial<Location>
  ) => {
    setSelectedLocation(location);
    
    form.setFieldsValue({
      location: {
        ...form.getFieldValue("location"),
        latitude: location.lat,
        longitude: location.lng,
        ...addressDetails,
      },
    });

    if (mapInstance.current) {
      mapInstance.current.setCenter(location);
      updateMarker(location);
    }
  };

  const updateMarker = (location: Coordinates) => {
    if (marker.current) {
      marker.current.setPosition(location);
    } else if (mapInstance.current) {
      marker.current = new window.google.maps.Marker({
        position: location,
        map: mapInstance.current,
        draggable: true,
      });
    }
  };

  const fetchStoreData = async () => {
    setIsLoading(true);
    try {
      const response = await getFoodStore();
      if (response) {
        setStore(response);
        form.setFieldsValue({
          name: response.name,
          description: response.description || "",
          ...(response.location && { location: response.location }),
        });
        
        if (response.location?.latitude && response.location?.longitude) {
          setSelectedLocation({
            lat: response.location.latitude,
            lng: response.location.longitude
          });
        }
      } else {
        setStore(null);
        form.resetFields();
      }
    } catch (err) {
      message.error(t("store.fetchError"));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchStoreData();
  }, []);

  useEffect(() => {
    if (isModalOpen && !mapLoaded) {
      loadGoogleMapsScript(() => {
        setMapLoaded(true);
        initializeMap();
      });
    }

    return () => {
      if (autocompleteRef.current) {
        window.google.maps.event.clearInstanceListeners(autocompleteRef.current);
      }
    };
  }, [isModalOpen]);

  useEffect(() => {
    if (mapLoaded && isModalOpen) {
      initializeMap();
    }
  }, [mapLoaded, isModalOpen, selectedLocation]);

  const deleteStore = async () => {
    Modal.confirm({
      title: t("store.delete.title"),
      content: t("store.delete.confirm"),
      okText: t("store.delete.button"),
      okButtonProps: { danger: true },
      cancelText: t("common.buttons.cancel"),
      onOk: async () => {
        setIsDeleting(true);
        try {
          await deleteFoodStore();
          setStore(null);
          message.success(t("store.delete.success"));
        } catch (err) {
          message.error(t("store.delete.error"));
        } finally {
          setIsDeleting(false);
        }
      },
    });
  };

  const handleSubmit = async (values: StoreFormValues) => {
    setIsLoading(true);
    try {
      const formData = new FormData();
      if (values.name) {
        formData.append("name", values.name);
      }
      if (values.description) {
        formData.append("description", values.description);
      }

      if (values.location) {
        Object.entries(values.location).forEach(([key, value]) => {
          if (value !== undefined && value !== null && value !== "") {
            formData.append(`location[${key}]`, String(value));
          }
        });
      }

      if (store) {
        await updateFoodStore(formData);
        
        if (fileList.length > 0 && fileList[0].originFileObj) {
          const imageFormData = new FormData();
          imageFormData.append("profileImage", fileList[0].originFileObj);
          await updateFoodStoreImage(imageFormData);
        }

        message.success(t("store.update.success"));
      } else {
        if (fileList.length > 0 && fileList[0].originFileObj) {
          formData.append("profileImage", fileList[0].originFileObj);
        }
        await createFoodStore(formData);
        message.success(t("store.create.success"));
      }

      await fetchStoreData();
      setIsModalOpen(false);
      setFileList([]);
    } catch (err) {
      message.error(
        store ? t("store.update.error") : t("store.create.error")
      );
    } finally {
      setIsLoading(false);
    }
  };

  const beforeUpload = (file: File) => {
    const isImage = file.type.startsWith("image/");
    if (!isImage) {
      message.error(t("store.form.validation.imageFormat"));
    }
    return isImage;
  };

  const handleFileChange = ({ fileList }: { fileList: UploadFile[] }) => {
    setFileList(fileList);
  };

  if (isLoading && !store) {
    return (
      <div style={{ textAlign: "center", marginTop: "50px" }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div style={{ maxWidth: "1200px", margin: "0 auto", padding: "20px" }}>
      <Card>
        {store ? (
          <>
            <Descriptions
              title={t("store.info.title")}
              bordered
              column={{ xs: 1, sm: 1, md: 2 }}
            >
              <Descriptions.Item label={t("store.info.name")} span={2}>
                {store.name}
              </Descriptions.Item>
              {store.description && (
                <Descriptions.Item label={t("store.info.description")} span={2}>
                  {store.description}
                </Descriptions.Item>
              )}
              {store.profileImageUrl && (
                <Descriptions.Item label={t("store.info.profileImage")} span={2}>
                  <Image
                    src={`${API_BASE_URL}${store.profileImageUrl}`}
                    alt="Store profile"
                    width={150}
                  />
                </Descriptions.Item>
              )}
              {store.address && (
                <>
                  <Descriptions.Item label={t("store.info.address")} span={2}>
                    {store.address.street && (
                      <>
                        {store.address.street}
                        <br />
                      </>
                    )}
                    {store.address.city && <>{store.address.city}, </>}
                    {store.address.state} {store.address.zipCode}
                    <br />
                    {store.address.country}
                  </Descriptions.Item>
                  {store.address.additionalDetails && (
                    <Descriptions.Item label={t("store.form.location.additionalDetails")}>
                      {store.address.additionalDetails}
                    </Descriptions.Item>
                  )}
                  <Descriptions.Item label={t("store.info.coordinates")}>
                    {t("store.info.latitude")}: {store.address.latitude}
                    <br />
                    {t("store.info.longitude")}: {store.address.longitude}
                  </Descriptions.Item>
                </>
              )}
            </Descriptions>

            <Divider />

            <Space>
              <Button
                type="primary"
                icon={<EditOutlined />}
                onClick={() => setIsModalOpen(true)}
              >
                {t("store.update.button")}
              </Button>
              <Button
                danger
                icon={<DeleteOutlined />}
                onClick={deleteStore}
                loading={isDeleting}
              >
                {t("store.delete.button")}
              </Button>
            </Space>
          </>
        ) : (
          <div style={{ textAlign: "center" }}>
            <h2>{t("store.noStore.title")}</h2>
            <p>{t("store.noStore.description")}</p>
            <Button
              type="primary"
              icon={<PlusOutlined />}
              onClick={() => setIsModalOpen(true)}
              style={{ marginTop: "20px" }}
            >
              {t("store.create.button")}
            </Button>
          </div>
        )}
      </Card>

      <Modal
        title={store ? t("store.update.title") : t("store.create.title")}
        open={isModalOpen}
        onCancel={() => {
          setIsModalOpen(false);
          setFileList([]);
        }}
        footer={null}
        width={800}
        destroyOnClose
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSubmit}
          initialValues={{
            name: "",
            description: "",
            ...(store?.location && { location: store.location }),
          }}
        >
          {!store && (
            <Form.Item<StoreFormValues>
              label={t("store.form.name")}
              name="name"
              rules={[
                { required: true, message: t("store.form.validation.nameRequired") },
                { max: 100, message: t("store.form.validation.nameMax") },
              ]}
            >
              <Input placeholder={t("store.form.namePlaceholder")} />
            </Form.Item>
          )}
          <Form.Item<StoreFormValues>
            label={t("store.form.description")}
            name="description"
            rules={[
              { max: 500, message: t("store.form.validation.descriptionMax") },
            ]}
          >
            <TextArea rows={3} placeholder={t("store.form.descriptionPlaceholder")} />
          </Form.Item>

          <Form.Item
            label={t("store.form.profileImage")}
            name="profileImage"
            rules={[
              {
                validator: (_,) => {
                  if (fileList.length > 0 && fileList[0].size && fileList[0].size > 5 * 1024 * 1024) {
                    return Promise.reject(new Error(t("store.form.validation.imageSize")));
                  }
                  return Promise.resolve();
                },
              },
            ]}
          >
            <Upload
              listType="picture-card"
              fileList={fileList}
              onChange={handleFileChange}
              beforeUpload={beforeUpload}
              maxCount={1}
              accept="image/*"
            >
              {fileList.length >= 1 ? null : (
                <div>
                  <PlusOutlined />
                  <div style={{ marginTop: 8 }}>{t("upload.hint")}</div>
                </div>
              )}
            </Upload>
            {store?.profileImageUrl && !fileList.length && (
              <p style={{ color: "#999" }}>{t("store.form.currentImage")}</p>
            )}
          </Form.Item>

          <Divider orientation="left">{t("store.form.location.title")}</Divider>

          <Form.Item label={t("store.form.location.search")}>
            <Input
              id="address-search"
              placeholder={t("store.form.location.searchPlaceholder")}
              prefix={<EnvironmentOutlined />}
            />
          </Form.Item>

          <div
            ref={mapRef}
            style={{
              height: "300px",
              width: "100%",
              minHeight: "300px",
              marginBottom: "20px",
              border: "1px solid #d9d9d9",
              borderRadius: "4px",
            }}
          />

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item<StoreFormValues>
                label={t("store.form.location.latitude")}
                name={["location", "latitude"]}
                rules={[
                  { required: true, message: t("store.form.validation.locationRequired") },
                  {
                    type: "number",
                    min: -90,
                    max: 90,
                    message: t("store.form.validation.latitudeRange"),
                  },
                ]}
              >
                <InputNumber
                  style={{ width: "100%" }}
                  onChange={(value) => {
                    if (value && mapInstance.current) {
                      const newLocation = {
                        lat: Number(value),
                        lng: form.getFieldValue(["location", "longitude"]) || 0,
                      };
                      handleLocationChange(newLocation);
                    }
                  }}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item<StoreFormValues>
                label={t("store.form.location.longitude")}
                name={["location", "longitude"]}
                rules={[
                  { required: true, message: t("store.form.validation.locationRequired") },
                  {
                    type: "number",
                    min: -180,
                    max: 180,
                    message: t("store.form.validation.longitudeRange"),
                  },
                ]}
              >
                <InputNumber
                  style={{ width: "100%" }}
                  onChange={(value) => {
                    if (value && mapInstance.current) {
                      const newLocation = {
                        lat: form.getFieldValue(["location", "latitude"]) || 0,
                        lng: Number(value),
                      };
                      handleLocationChange(newLocation);
                    }
                  }}
                />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item<StoreFormValues>
            label={t("store.form.location.street")}
            name={["location", "street"]}
            rules={[
              { max: 100, message: t("store.form.validation.streetMax") },
            ]}
          >
            <Input />
          </Form.Item>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item<StoreFormValues>
                label={t("store.form.location.city")}
                name={["location", "city"]}
                rules={[
                  { max: 50, message: t("store.form.validation.cityMax") },
                ]}
              >
                <Input />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item<StoreFormValues>
                label={t("store.form.location.state")}
                name={["location", "state"]}
                rules={[
                  { max: 50, message: t("store.form.validation.stateMax") },
                ]}
              >
                <Input />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item<StoreFormValues>
                label={t("store.form.location.zipCode")}
                name={["location", "zipCode"]}
                rules={[
                  { max: 20, message: t("store.form.validation.zipMax") },
                ]}
              >
                <Input />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item<StoreFormValues>
                label={t("store.form.location.country")}
                name={["location", "country"]}
                rules={[
                  { max: 50, message: t("store.form.validation.countryMax") },
                ]}
              >
                <Input />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item<StoreFormValues>
            label={t("store.form.location.additionalDetails")}
            name={["location", "additionalDetails"]}
            rules={[
              { max: 200, message: t("store.form.validation.additionalMax") },
            ]}
          >
            <TextArea rows={2} placeholder={t("store.form.location.additionalDetailsPlaceholder")} />
          </Form.Item>

          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              loading={isLoading}
              block
              size="large"
            >
              {store ? t("store.update.button") : t("store.create.button")}
            </Button>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default CreateStore;