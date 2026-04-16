import { useState, useEffect } from "react";
import { adminVerificationService } from "../../services/adminVerificationService";
import {
  Button,
  Card,
  Table,
  Tag,
  Space,
  Modal,
  Input,
  message,
  Spin,
  Typography,
  Tooltip,
  Dropdown,
  List,
  Menu,
} from "antd";
import type { ColumnsType } from "antd/es/table";
import {
  DownloadOutlined,
  CheckOutlined,
  CloseOutlined,
  InfoCircleOutlined,
  EyeOutlined,
} from "@ant-design/icons";
import { VerificationRequest } from "../../types/store";
import { useTranslation } from "react-i18next";

const { Title, Text } = Typography;

const VerificationRequestsPage = () => {
  const { t } = useTranslation();
  const [requests, setRequests] = useState<VerificationRequest[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [selectedRequest, setSelectedRequest] =
    useState<VerificationRequest | null>(null);
  const [adminComment, setAdminComment] = useState("");
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [modalAction, setModalAction] = useState<"approve" | "reject">(
    "approve"
  );
  const [documentPreviewVisible, setDocumentPreviewVisible] = useState(false);
  const [previewDocument, setPreviewDocument] = useState<string | null>(null);
  const [previewLoading, setPreviewLoading] = useState(false);

  const fetchRequests = async (page: number = 1, pageSize: number = 10) => {
    try {
      setLoading(true);
      const response = await adminVerificationService.getVerificationRequests(
        page,
        pageSize
      );
      setRequests(response.data);
      setPagination({
        current: response.current_page,
        pageSize: response.limit,
        total: response.total_items,
      });
    } catch (error) {
      message.error(t("verification.messages.fetchError"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRequests();
  }, []);

  const handleTableChange = (pagination: any) => {
    fetchRequests(pagination.current, pagination.pageSize);
  };

  const handleDownload = async (requestId: string, documentId: string) => {
    try {
      setLoading(true);
      const response =
        await adminVerificationService.downloadVerificationDocument(
          requestId,
          documentId
        );

      let filename = `document_${documentId}.pdf`;
      const contentDisposition = response.headers["content-disposition"];
      if (contentDisposition) {
        const filenameMatch = contentDisposition.match(/filename="?([^"]+)"?/);
        if (filenameMatch && filenameMatch[1]) {
          filename = filenameMatch[1];
          if (!filename.endsWith(".pdf")) {
            filename += ".pdf";
          }
        }
      }

      const blob = new Blob([response.data], {
        type: "application/pdf",
      });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();

      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);

      message.success(t("verification.messages.downloadSuccess", { filename }));
    } catch (error) {
      message.error(t("verification.messages.downloadError"));
      console.error("Download error:", error);
    } finally {
      setLoading(false);
    }
  };

  const handlePreview = async (requestId: string, mediaId: string) => {
    try {
      setPreviewLoading(true);
      const response =
        await adminVerificationService.downloadVerificationDocument(
          requestId,
          mediaId
        );
      const blob = new Blob([response.data], { type: "application/pdf" });
      const url = window.URL.createObjectURL(blob);

      setPreviewDocument(url);
      setDocumentPreviewVisible(true);
    } catch (error) {
      message.error(t("verification.messages.previewError"));
    } finally {
      setPreviewLoading(false);
    }
  };

  const showModal = (
    request: VerificationRequest,
    action: "approve" | "reject"
  ) => {
    setSelectedRequest(request);
    setModalAction(action);
    if (request.adminComment) {
      setAdminComment(request.adminComment);
    } else {
      setAdminComment("");
    }
    setIsModalVisible(true);
  };

  const handleOk = async () => {
    if (!selectedRequest) return;

    try {
      setLoading(true);
      if (modalAction === "approve") {
        await adminVerificationService.approveVerificationRequest(
          selectedRequest.id,
          adminComment
        );
        message.success(t("verification.messages.approveSuccess"));
      } else {
        if (!adminComment) {
          message.error(t("verification.messages.rejectNoteRequired"));
          return;
        }
        await adminVerificationService.rejectVerificationRequest(
          selectedRequest.id,
          adminComment
        );
        message.success(t("verification.messages.rejectSuccess"));
      }
      setIsModalVisible(false);
      setAdminComment("");
      fetchRequests(pagination.current, pagination.pageSize);
    } catch (error) {
      message.error(t("verification.messages.processError"));
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    setIsModalVisible(false);
    setAdminComment("");
    setSelectedRequest(null);
  };

  const getStatusTag = (status: string) => {
    switch (status) {
      case "pending":
        return <Tag color="orange">{t("verification.status.pending")}</Tag>;
      case "approved":
        return <Tag color="green">{t("verification.status.approved")}</Tag>;
      case "rejected":
        return <Tag color="red">{t("verification.status.rejected")}</Tag>;
      default:
        return <Tag>{status}</Tag>;
    }
  };

  const renderDocuments = (documents: any[]) => {
    return (
      <List
        size="small"
        dataSource={documents}
        renderItem={(doc: any) => (
          <List.Item>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                width: "100%",
              }}
            >
              <div>
                <Text
                  ellipsis
                  style={{ maxWidth: 150, display: "inline-block" }}
                >
                  {doc.originalName}
                </Text>
              </div>
              <Space>
                <Button
                  size="small"
                  icon={<EyeOutlined />}
                  onClick={() => handlePreview(doc.requestId, doc.id)}
                  loading={previewLoading}
                >
                  {t("verification.buttons.preview")}
                </Button>
                <Button
                  size="small"
                  icon={<DownloadOutlined />}
                  onClick={() => handleDownload(doc.requestId, doc.id)}
                >
                  {t("verification.buttons.download")}
                </Button>
              </Space>
            </div>
          </List.Item>
        )}
      />
    );
  };

  const columns: ColumnsType<VerificationRequest> = [
    {
      title: t("verification.table.columns.storeName"),
      dataIndex: "foodStoreName",
      key: "foodStoreName",
      render: (text, _) => (
          <div>{text}</div>
      ),
    },
    {
      title: t("verification.table.columns.status"),
      dataIndex: "status",
      key: "status",
      render: (status, record) => (
        <div>
          {getStatusTag(status)}
          {record.processedAt && (
            <div style={{ fontSize: 12, marginTop: 4 }}>
              <Text type="secondary">
                {new Date(record.processedAt).toLocaleString()}
              </Text>
            </div>
          )}
        </div>
      ),
    },
    {
      title: t("verification.table.columns.submittedAt"),
      dataIndex: "createdAt",
      key: "createdAt",
      render: (date) => new Date(date).toLocaleString(),
    },
    {
      title: t("verification.table.columns.actions"),
      key: "actions",
      width: 250,
      render: (_, record) => (
        <Space size="middle">
          {record.documentIds?.length > 0 && (
            <>
              <Dropdown
                overlay={
                  <Menu>
                    {record.documentIds.map((docId: string, index: number) => (
                      <div key={index} className="flex items-center justify-between p-2">
                        <Menu.Item
                          key={`download-${docId}`}
                          onClick={() => handleDownload(record.id, docId)}
                        >
                          <Space>
                            <DownloadOutlined />
                          </Space>

                        </Menu.Item>
                        <Menu.Item
                          key={`preview-${docId}`}
                          onClick={() => handlePreview(record.id, docId)}
                        >
                          <Space>
                            <EyeOutlined />
                          </Space>
                        </Menu.Item>
                      </div>
                    ))}
                  </Menu>
                }
              >
                <Button icon={<DownloadOutlined />}>
                  {t("verification.buttons.documents")}
                </Button>
              </Dropdown>
            </>
          )}

          {record.status === "pending" && (
            <>
              <Tooltip title={t("verification.buttons.approve")}>
                <Button
                  type="primary"
                  icon={<CheckOutlined />}
                  onClick={() => showModal(record, "approve")}
                />
              </Tooltip>
              <Tooltip title={t("verification.buttons.reject")}>
                <Button
                  danger
                  icon={<CloseOutlined />}
                  onClick={() => showModal(record, "reject")}
                />
              </Tooltip>
            </>
          )}

          {record.adminComment && (
            <Tooltip title={t("verification.buttons.viewDetails")}>
              <Button
                icon={<InfoCircleOutlined />}
                onClick={() =>
                  showModal(
                    record,
                    record.status === "approved" ? "approve" : "reject"
                  )
                }
              />
            </Tooltip>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div className="p-6">
      <Title level={2}>{t("verification.title")}</Title>
      <Card>
        <Spin spinning={loading}>
          <Table
            columns={columns}
            dataSource={requests}
            rowKey="id"
            pagination={pagination}
            onChange={handleTableChange}
            scroll={{ x: true }}
          />
        </Spin>
      </Card>

      <Modal
        title={
          modalAction === "approve"
            ? t("verification.modal.approveTitle")
            : t("verification.modal.rejectTitle")
        }
        open={isModalVisible}
        onOk={handleOk}
        onCancel={handleCancel}
        confirmLoading={loading}
        width={700}
      >
        {selectedRequest && (
          <div>
            <div style={{ marginBottom: 16 }}>
              <Text strong>{t("verification.modal.storeLabel")}</Text>{" "}
              {selectedRequest.foodStoreName}
            </div>

            <div style={{ marginBottom: 16 }}>
              <Text strong>{t("verification.modal.documentsLabel")}</Text>
              {selectedRequest.documents?.length > 0 ? (
                renderDocuments(selectedRequest.documents)
              ) : (
                <Text type="secondary">
                  {t("verification.table.noDocuments")}
                </Text>
              )}
            </div>

            <div style={{ marginBottom: 16 }}>
              <Text strong>{t("verification.modal.statusLabel")}</Text>{" "}
              {getStatusTag(selectedRequest.status)}
            </div>

            {selectedRequest.processedAt && (
              <div style={{ marginBottom: 16 }}>
                <Text strong>{t("verification.modal.processedLabel")}</Text>{" "}
                {new Date(selectedRequest.processedAt).toLocaleString()}
              </div>
            )}

            <div className="mt-4">
              <Text strong>
                {modalAction === "approve"
                  ? t("verification.modal.approveNote")
                  : t("verification.modal.rejectNote")}
              </Text>
              <Input.TextArea
                rows={4}
                value={adminComment}
                onChange={(e) => setAdminComment(e.target.value)}
                placeholder={
                  modalAction === "approve"
                    ? t("verification.modal.approvePlaceholder")
                    : t("verification.modal.rejectPlaceholder")
                }
                style={{ marginTop: 8 }}
              />
              {selectedRequest.adminComment && (
                <div style={{ marginTop: 8 }}>
                  <Text type="secondary">
                    {t("verification.modal.previousNote")}{" "}
                    {selectedRequest.adminComment}
                  </Text>
                </div>
              )}
            </div>
          </div>
        )}
      </Modal>

      <Modal
        open={documentPreviewVisible}
        title={t("verification.modal.documentPreview")}
        footer={null}
        onCancel={() => {
          setDocumentPreviewVisible(false);
          if (previewDocument) {
            URL.revokeObjectURL(previewDocument);
            setPreviewDocument(null);
          }
        }}
        width="80%"
        style={{ top: 20 }}
      >
        <Spin spinning={previewLoading}>
          {previewDocument && (
            <div
              style={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center",
                minHeight: "500px",
              }}
            >
              <iframe
                src={previewDocument}
                style={{ width: "100%", height: "500px", border: "none" }}
                title={t("verification.modal.documentPreview")}
              />
            </div>
          )}
        </Spin>
      </Modal>
    </div>
  );
};

export default VerificationRequestsPage;
