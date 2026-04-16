import React, { useEffect, useState } from 'react';
import { Row, Col, Tabs, message, Card, InputNumber, Button } from 'antd';
import WalletBalance from './WalletBalance';
import TransactionsList from './TransactionsList';
import { WalletDTO, TransactionDTO } from '../../types/wallet';
import API from '../../services/httpClient';
import { useTranslation } from 'react-i18next';
import { Form } from 'antd';
import EmptyState from '../../components/EmptyState';
import { SkeletonCard, SkeletonTableRows } from '../../components/SkeletonLoader';

const WalletEmptyIcon = (
  <svg viewBox="0 0 64 64" fill="none" className="w-full h-full" stroke="currentColor">
    <rect x="8" y="20" width="48" height="32" rx="4" strokeWidth="3"/>
    <path strokeLinecap="round" strokeWidth="3" d="M8 28h48"/>
    <circle cx="42" cy="40" r="6" strokeWidth="3"/>
    <path strokeLinecap="round" strokeWidth="2" d="M8 12h40a4 4 0 014 4v4"/>
  </svg>
);

const { TabPane } = Tabs;

const WalletPage: React.FC = () => {
  const { t } = useTranslation();
  const [wallet, setWallet] = useState<WalletDTO | null>(null);
  const [transactions, setTransactions] = useState<TransactionDTO[]>([]);
  const [stripeStatus, setStripeStatus] = useState<any>(null);
  const [loading, setLoading] = useState({
    wallet: true,
    transactions: true,
    cards: true,
  });
  const [walletError, setWalletError] = useState(false);
  const [form] = Form.useForm();


  useEffect(() => {
    fetchStripeStatus();
  }, []);

  const fetchStripeStatus = async () => {
    const response = await API.get('seller/food-store/stripe/status');
    setStripeStatus(response.data);
  };

  const fetchWallet = async () => {
    try {
      setWalletError(false);
      const response = await API.get('/seller/food-store/wallet');
      if (!response) throw new Error(t('wallet.messages.fetchWalletError'));
      const data = await response.data;
      setWallet(data);
    } catch {
      setWalletError(true);
    } finally {
      setLoading((prev) => ({ ...prev, wallet: false }));
    }
  };

  const fetchTransactions = async () => {
    try {
      const response = await API.get('/seller/food-store/wallet/transactions');
      if (!response) throw new Error(t('wallet.messages.fetchTransactionsError'));
      const data = await response.data;
      setTransactions(data);
    } catch (error: unknown) {
      if (error instanceof Error) {
        message.error(error.message);
      } else {
        message.error(t('wallet.messages.unknownError'));
      }
    } finally {
      setLoading((prev) => ({ ...prev, transactions: false }));
    }
  };

  useEffect(() => {

    fetchWallet();
    fetchTransactions();
  }, [t]);

  const requestPayout = async (values: any) => {
    // Check if wallet is active before allowing payout
    if (wallet && !wallet.isActive) {
      message.error(t('stripe.walletBlocked') || 'Wallet is blocked. Cannot request payout.');
      return;
    }
    
    var response = await API.post('seller/food-store/stripe/payout', values);
    if (response.status === 200) {
      message.success(t('stripe.payoutRequestSuccess'));
      fetchWallet();
      fetchTransactions();
    } else {
      message.error(t('stripe.payoutRequestError'));
    }
  };

  if (loading.wallet && !wallet) {
    return (
      <div style={{ padding: '24px' }}>
        <SkeletonCard height={120} />
        <div style={{ marginTop: 16 }}>
          <SkeletonTableRows rows={5} />
        </div>
      </div>
    );
  }

  if (walletError && !wallet) {
    return (
      <EmptyState
        icon={WalletEmptyIcon}
        title="Portefeuille indisponible"
        description="Impossible de charger les données du portefeuille. Le serveur ne répond pas."
        onRetry={() => { setWalletError(false); fetchWallet(); fetchTransactions(); }}
      />
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <Row gutter={[24, 24]}>
        <Col span={24}>
          <WalletBalance wallet={wallet!} loading={loading.wallet} />
        </Col>
        <Col span={24}>

          {stripeStatus?.onboarding_complete && (
            <Card title={t('stripe.request_payout')} style={{ marginTop: 24 }}>
              <Form form={form} layout="vertical" onFinish={requestPayout}>
                <Form.Item label={t('stripe.amount')} name="amount" rules={[{ required: true }, { type: 'number', min: 1 }]}>
                  <InputNumber style={{ width: '100%' }} precision={2} />
                </Form.Item>
                <Button type="primary" htmlType="submit">{t('stripe.request_payout_button')}</Button>
              </Form>
            </Card>
          )}
        </Col>
        <Col span={24}>
          <Tabs defaultActiveKey="1">
            <TabPane tab={t('wallet.tabs.transactions')} key="1">
              <TransactionsList transactions={transactions} loading={loading.transactions} />
            </TabPane>
          </Tabs>
        </Col>
      </Row>
    </div>
  );
};

export default WalletPage;