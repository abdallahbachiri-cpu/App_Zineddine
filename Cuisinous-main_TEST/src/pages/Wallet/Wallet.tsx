import React, { useEffect, useState } from 'react';
import { Row, Col, Tabs, Spin, message, Card, InputNumber, Button } from 'antd';
import WalletBalance from './WalletBalance';
import TransactionsList from './TransactionsList';
import { WalletDTO, TransactionDTO } from '../../types/wallet';
import API from '../../services/api';
import { useTranslation } from 'react-i18next';
import { Form } from 'antd';

const { TabPane } = Tabs;

const Wallet: React.FC = () => {
  const { t } = useTranslation();
  const [wallet, setWallet] = useState<WalletDTO | null>(null);
  const [transactions, setTransactions] = useState<TransactionDTO[]>([]);
  const [stripeStatus, setStripeStatus] = useState<any>(null);
  const [loading, setLoading] = useState({
    wallet: true,
    transactions: true,
    cards: true,
  });
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
      const response = await API.get('/seller/food-store/wallet');
      if (!response) throw new Error(t('wallet.messages.fetchWalletError'));
      const data = await response.data;
      setWallet(data);
    } catch (error: unknown) {
      if (error instanceof Error) {
        message.error(error.message);
      } else {
        message.error(t('wallet.messages.unknownError'));
      }
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
      <Spin
        size="large"
        style={{ display: 'flex', justifyContent: 'center', marginTop: '20%' }}
        tip={t('wallet.loading')}
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

export default Wallet;