import React, { useEffect, useState } from 'react';
import { Form, InputNumber, Button, Card, Typography, Spin, message } from 'antd';
import { useTranslation } from 'react-i18next';
import api from '../services/httpClient';

const { Title } = Typography;

interface PayoutConfig {
  commissionRate?: number;
  minimumPayout?: number;
  maximumPayout?: number;
  payoutCooldownHours?: number;
}

const PayoutConfiguration: React.FC = () => {
  const { t } = useTranslation();
  const [form] = Form.useForm();
  const [loading, setLoading] = useState<boolean>(true);
  const [submitting, setSubmitting] = useState<boolean>(false);

  useEffect(() => {
    fetchPayoutConfig();
  }, []);

  const fetchPayoutConfig = async () => {
    try {
      setLoading(true);
      const response = await api.get('/admin/payout-config');
      if (response.data) {
        form.setFieldsValue(response.data);
      }
    } catch (error) {
      message.error(t('payoutConfig.fetchError'));
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (values: PayoutConfig) => {
    try {
      setSubmitting(true);
      
      const processedValues = {
        commissionRate: values.commissionRate ?? form.getFieldValue('commissionRate') ?? 0,
        minimumPayout: values.minimumPayout ?? form.getFieldValue('minimumPayout') ?? 0,
        maximumPayout: values.maximumPayout ?? form.getFieldValue('maximumPayout') ?? 0,
        payoutCooldownHours: values.payoutCooldownHours ?? form.getFieldValue('payoutCooldownHours') ?? 0,
      };
            
      await api.post('/admin/payout-config', processedValues);
      message.success(t('payoutConfig.updateSuccess'));
    } catch (error: any) {
      if (error.response?.data?.errors) {
        const errors = error.response.data.errors;
        form.setFields(
          Object.keys(errors).map(fieldName => ({
            name: fieldName,
            errors: [errors[fieldName]],
          }))
        );
      } else {
        message.error(t('payoutConfig.updateError'));
      }
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Card>
      <Title level={3}>{t('payoutConfig.title')}</Title>
      <Spin spinning={loading}>
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSubmit}
          initialValues={{
            commissionRate: 0,
            minimumPayout: 0,
            maximumPayout: 0,
            payoutCooldownHours: 0,
          }}
        >
          <Form.Item
            name="commissionRate"
            label={t('payoutConfig.commissionRate' + " (%)")}
        
          >
            <InputNumber
              style={{ width: '100%' }}
              min={0}
              max={100}
              step={0.1}
              value={form.getFieldValue('commissionRate') !== undefined ? form.getFieldValue('commissionRate') * 100 : undefined}
            />
          </Form.Item>

          <Form.Item
            name="minimumPayout"
            label={t('payoutConfig.minimumPayout') + " (CAD)"}
            
          >
            <InputNumber
              style={{ width: '100%' }}
              min={0}
            />
          </Form.Item>

          <Form.Item
            name="maximumPayout"
            label={t('payoutConfig.maximumPayout' + " (CAD)")}
          >
            <InputNumber
              style={{ width: '100%' }}
              min={0}
            />
          </Form.Item>

          <Form.Item
            name="payoutCooldownHours"
            label={t('payoutConfig.payoutCooldownHours')}

          >
            <InputNumber
              style={{ width: '100%' }}
              min={0}
              step={1}
            />
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={submitting}>
              {t('payoutConfig.saveButton')}
            </Button>
          </Form.Item>
        </Form>
      </Spin>
    </Card>
  );
};

export default PayoutConfiguration;