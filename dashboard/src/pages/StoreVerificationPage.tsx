import { useState, useEffect } from 'react';
import { verificationService } from '../services/verificationService';
import { Button, Card, message, Upload, Spin, List, Alert } from 'antd';
import type { UploadProps } from 'antd';
import { UploadOutlined, DeleteOutlined, DownloadOutlined } from '@ant-design/icons';
import { useTranslation } from 'react-i18next';

const StoreVerificationPage = () => {
  const { t } = useTranslation();
  const [files, setFiles] = useState<File[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [verificationStatus, setVerificationStatus] = useState<any>(null);
  const [verificationRequest, setVerificationRequest] = useState<any>(null);
  const [adminComment, setAdminComment] = useState<string | null>(null);

  useEffect(() => {
    checkVerificationStatus();
  }, []);

  const checkVerificationStatus = async () => {
    try {
      setIsLoading(true);
      const response = await verificationService.getVerificationRequests();
      
      if (response.data && response.data.length > 0) {
        const request = response.data[0];
        setVerificationStatus(request.status);
        setVerificationRequest(request);
        
        if (request.status === 'rejected' && request.adminComment) {
          setAdminComment(request.adminComment);
        } else {
          setAdminComment(null);
        }
      }
    } catch (error) {
      // Error handling is silent here as per original implementation
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async () => {
    if (files.length === 0) {
      message.error(t('storeVerification.messages.noFilesError'));
      return;
    }

    try {
      setIsLoading(true);
      await verificationService.submitVerificationRequest(files);
      message.success(t('storeVerification.messages.submitSuccess'));
      setVerificationStatus('pending');
      setFiles([]);
      setAdminComment(null);
      await checkVerificationStatus();
    } catch (error: any) {
      if (error.response?.data?.error) {
        message.error(error.response.data.error);
      } else if (error.response?.data?.errors) {
        message.error(error.response.data.errors.join(', '));
      } else {
        message.error(t('storeVerification.messages.submitError'));
      }
    } finally {
      setIsLoading(false);
    }
  };

  const props: UploadProps = {
    beforeUpload: (file) => {
      const isValidType = [
        'application/pdf',
        'image/jpeg',
        'image/png',
      ].includes(file.type);
      
      if (!isValidType) {
        message.error(t('storeVerification.messages.fileTypeError'));
        return false;
      }
      
      if (files.length >= 15) {
        message.error(t('storeVerification.messages.fileLimitError'));
        return false;
      }
      
      setFiles(prev => [...prev, file]);
      return false;
    },
    multiple: true,
    accept: '.pdf,.jpg,.jpeg,.png',
    showUploadList: false,
  };

  const removeFile = (index: number) => {
    setFiles(prev => prev.filter((_, i) => i !== index));
  };

  const getStatusMessage = () => {
    switch (verificationStatus) {
      case 'pending':
        return t('storeVerification.status.pending');
      case 'approved':
        return t('storeVerification.status.approved');
      case 'rejected':
        return t('storeVerification.status.rejected');
      default:
        return t('storeVerification.status.default');
    }
  };

  const downloadDocument = async (mediaId: string) => {
    try {
      if (!verificationRequest?.id) return;
      
      const response = await verificationService.downloadVerificationDocument(
        verificationRequest.id,
        mediaId
      );
      
      const blob = new Blob([response.data], { type: response.headers['content-type'] });
      const url = window.URL.createObjectURL(blob);
      
      const a = document.createElement('a');
      a.href = url;
      a.download = `document_${mediaId}`;
      document.body.appendChild(a);
      a.click();
      
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    } catch (error) {
      message.error(t('storeVerification.messages.downloadError'));
    }
  };

  return (
    <div className="p-6">
      <Card title={t('storeVerification.title')} className="mx-auto">
        <Spin spinning={isLoading}>
          <div className="mb-4">
            <p className="text-lg font-medium mb-2">Status: {getStatusMessage()}</p>
            
            {verificationStatus === 'rejected' && adminComment && (
              <Alert
                message={t('storeVerification.adminFeedback')}
                description={adminComment}
                type="error"
                showIcon
                className="my-3"
              />
            )}
            
            {verificationStatus === 'approved' && (
              <p className="text-green-500">{t('storeVerification.status.approvedMessage')}</p>
            )}
          </div>

          {verificationRequest?.documents?.length > 0 && (
            <div className="mb-4">
              <h4 className="mb-2">{t('storeVerification.submittedDocuments')}</h4>
              <List
                bordered
                dataSource={verificationRequest.documents}
                renderItem={(doc: any) => (
                  <List.Item
                    actions={[
                      <Button
                        icon={<DownloadOutlined />}
                        onClick={() => downloadDocument(doc.id)}
                        size="small"
                      >
                        {t('storeVerification.buttons.download')}
                      </Button>
                    ]}
                  >
                    <List.Item.Meta
                      title={doc.originalName}
                      description={`${doc.mimeType} - ${(doc.size / 1024).toFixed(2)} KB`}
                    />
                  </List.Item>
                )}
              />
            </div>
          )}

          {!verificationStatus || verificationStatus === 'rejected' ? (
            <>
              <div className="mb-4">
                <p className="mb-2">
                  {t('storeVerification.upload.title')}
                </p>
                <p className="text-sm text-gray-500 mb-2">
                  {t('storeVerification.upload.formats')}
                </p>
                <Upload {...props}>
                  <Button icon={<UploadOutlined />}>{t('storeVerification.upload.selectFiles')}</Button>
                </Upload>
                
                {files.length > 0 && (
                  <div className="mt-4">
                    <List
                      bordered
                      dataSource={files}
                      renderItem={(file, index) => (
                        <List.Item
                          actions={[
                            <Button
                              icon={<DeleteOutlined />}
                              onClick={() => removeFile(index)}
                              size="small"
                              danger
                            >
                              {t('storeVerification.buttons.delete')}
                            </Button>
                          ]}
                        >
                          <List.Item.Meta
                            title={file.name}
                            description={`${file.type} - ${(file.size / 1024).toFixed(2)} KB`}
                          />
                        </List.Item>
                      )}
                    />
                    <p className="mt-2 text-sm">
                      {t('storeVerification.upload.filesSelected', { count: files.length })}
                    </p>
                  </div>
                )}
              </div>
              <Button
                type="primary"
                onClick={handleSubmit}
                disabled={files.length === 0}
                loading={isLoading}
              >
                {t('storeVerification.buttons.submit')}
              </Button>
            </>
          ) : verificationStatus === 'pending' && (
            <Button
              danger
              onClick={async () => {
                try {
                  setIsLoading(true);
                  await verificationService.deleteVerificationRequest(verificationRequest.id);
                  message.success(t('storeVerification.messages.cancelSuccess'));
                  setVerificationStatus(null);
                  setVerificationRequest(null);
                  setAdminComment(null);
                } catch (error) {
                  message.error(t('storeVerification.messages.cancelError'));
                } finally {
                  setIsLoading(false);
                }
              }}
              loading={isLoading}
            >
              {t('storeVerification.buttons.cancel')}
            </Button>
          )}
        </Spin>
      </Card>
    </div>
  );
};

export default StoreVerificationPage;