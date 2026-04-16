import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Spin, Result, Button } from 'antd';
import { useTranslation } from 'react-i18next';
import API from '../services/httpClient';

const StripeReturnUrl = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [verifying, setVerifying] = useState(true);
  const [status, setStatus] = useState<any>(null);
  const [, setError] = useState('');

  useEffect(() => {
    checkFinalStatus();
  }, []);

  const checkFinalStatus = async () => {
    try {
      const response = await API.get('seller/food-store/stripe/status');
      setStatus(response.data);
    } catch (err) {
      setError(t('stripe.returnUrl.failed_to_verify_status'));
    } finally {
      setVerifying(false);
    }
  };

  const handleRetrySetup = async () => {
    setVerifying(true);
    try {
      const response = await API.post('seller/food-store/stripe/setup');
      window.location.href = response.data.onboarding_url;
    } catch (err) {
      setError(t('stripe.returnUrl.failed_to_generate_link'));
      setVerifying(false);
    }
  };

  if (verifying) return <div style={{ textAlign: 'center', marginTop: 100 }}><Spin size="large" /></div>;

  if (status?.onboarding_complete) {
    return (
      <Result
        status="success"
        title={t('stripe.returnUrl.onboarding_complete')}
        extra={<Button type="primary" onClick={() => navigate('/')}>{t('stripe.returnUrl.back_to_dashboard')}</Button>}
      />
    );
  }

  return (
    <Result
      status="warning"
      title={t('stripe.returnUrl.onboarding_not_finished')}
      subTitle={t('stripe.returnUrl.onboarding_not_finished_description')}
      extra={[
        <Button type="primary" onClick={handleRetrySetup}>{t('stripe.returnUrl.complete_setup')}</Button>,
        <Button onClick={() => navigate('/')}>{t('stripe.returnUrl.cancel')}</Button>
      ]}
    />
  );
};

export default StripeReturnUrl;