import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Button, Card, Spin, Alert, Result, Typography } from 'antd';
import { LoadingOutlined, CheckCircleOutlined } from '@ant-design/icons';
import API from '../services/httpClient';
const { Title } = Typography;

const SellerPayout = () => {
  const { t } = useTranslation();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success,] = useState('');
  const [stripeStatus, setStripeStatus] = useState<any>(null);

  useEffect(() => {
    fetchStripeStatus();
  }, []);

  const fetchStripeStatus = async () => {
    setLoading(true);
    try {
      const response = await API.get('seller/food-store/stripe/status');
      setStripeStatus(response.data);
    } catch (err) {
      setError(t('stripe.failed_to_load_status'));
    } finally {
      setLoading(false);
    }
  };

  const handleStartOnboarding = async () => {
    setLoading(true);
    try {
      const response = await API.post('seller/food-store/stripe/setup');
      if (response.data.onboarding_url) {
        // IMPORTANT: Redirect to external Stripe URL
        window.location.href = response.data.onboarding_url;
      }
    } catch (err) {
      setError(t('stripe.failed_to_create_account'));
    } finally {
      setLoading(false);
    }
  };

  const renderStatusCard = () => {
    if (!stripeStatus) return null;

    if (!stripeStatus.has_stripe_account || !stripeStatus.onboarding_complete) {
      return (
        <Card title={stripeStatus.has_stripe_account ? t('stripe.complete_onboarding') : t('stripe.setup_account')}>
          <p>{stripeStatus.has_stripe_account ? t('stripe.onboarding_incomplete') : t('stripe.no_account_description')}</p>
          <Button type="primary" onClick={handleStartOnboarding} loading={loading}>
            {stripeStatus.has_stripe_account ? t('stripe.complete_onboarding_button') : t('stripe.setup_button')}
          </Button>
        </Card>
      );
    }

    return (
      <Card title={t('stripe.account_active')}>
        <Result
          icon={<CheckCircleOutlined style={{ color: '#52c41a' }} />}
          title={t('stripe.account_ready')}
          subTitle={t('stripe.can_receive_payments')}
        />
      </Card>
    );
  };

  return (
    <div className='p-8'>
      <Title level={2}>{t('stripe.title')}</Title>
      {error && <Alert message={error} type="error" showIcon closable style={{ marginBottom: 24 }} />}
      {success && <Alert message={success} type="success" showIcon closable style={{ marginBottom: 24 }} />}
      {loading && !stripeStatus ? <Spin indicator={<LoadingOutlined style={{ fontSize: 24 }} spin />} /> : (
        <>
          {renderStatusCard()}
        </>
      )}
    </div>
  );
};

export default SellerPayout;