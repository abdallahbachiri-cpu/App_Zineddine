import { useState, useEffect } from 'react';
import { Spin, Typography, Alert, Button } from 'antd';
import { LoadingOutlined } from '@ant-design/icons';
import { useTranslation } from 'react-i18next';
import API from '../services/api';

const StripeRefreshUrl = () => {
  const { t } = useTranslation();
  const [error, setError] = useState('');

  useEffect(() => {
    const refreshLink = async () => {
      try {
        const response = await API.post('seller/food-store/stripe/setup');
        if (response.data.onboarding_url) {
          window.location.href = response.data.onboarding_url;
        }
      } catch (err) {
        setError(t('stripe.refreshUrl.session_expired'));
      }
    };
    refreshLink();
  }, []);

  return (
    <div style={{ textAlign: 'center', marginTop: 100 }}>
      {!error ? (
        <>
          <Spin indicator={<LoadingOutlined style={{ fontSize: 48 }} spin />} />
          <Typography.Paragraph style={{ marginTop: 20 }}>
            {t('stripe.refreshUrl.redirecting_message')}
          </Typography.Paragraph>
        </>
      ) : (
        <div style={{ maxWidth: 400, margin: '0 auto' }}>
          <Alert message={t('stripe.refreshUrl.error')} description={error} type="error" showIcon />
          <Button href="/seller/payout" style={{ marginTop: 20 }}>{t('stripe.refreshUrl.return_to_payout_settings')}</Button>
        </div>
      )}
    </div>
  );
};

export default StripeRefreshUrl;