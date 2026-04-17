import React, { useEffect, useState } from 'react';
import { Row, Col, Tabs, message, Card, InputNumber, Button } from 'antd';
import WalletBalance from './WalletBalance';
import TransactionsList from './TransactionsList';
import { WalletDTO, TransactionDTO } from '../../types/wallet';
import API from '../../services/httpClient';
import { useTranslation } from 'react-i18next';
import { Form } from 'antd';


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
    try {
      const response = await API.get('seller/food-store/stripe/status');
      setStripeStatus(response.data);
    } catch {
      // silently ignore — stripe status is optional
    }
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

  // Always render — use empty defaults so page is never blank
  const displayWallet = wallet ?? { availableBalance: '0.00', currency: 'CAD', isActive: true };

  return (
    <div style={{ padding: '24px' }}>
      {walletError && (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: '#fff7ed', border: '1px solid #fed7aa', borderRadius: 8, padding: '10px 16px', marginBottom: 16 }}>
          <span style={{ fontSize: 13, color: '#c2410c' }}>⚠️ Impossible de charger le portefeuille. Le serveur ne répond pas.</span>
          <button onClick={() => { setWalletError(false); fetchWallet(); fetchTransactions(); }} style={{ fontSize: 12, fontWeight: 600, color: '#c2410c', textDecoration: 'underline', background: 'none', border: 'none', cursor: 'pointer', marginLeft: 12 }}>Réessayer</button>
        </div>
      )}
      <Row gutter={[24, 24]}>
        <Col span={24}>
          <WalletBalance wallet={displayWallet as any} loading={loading.wallet && !wallet} />
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