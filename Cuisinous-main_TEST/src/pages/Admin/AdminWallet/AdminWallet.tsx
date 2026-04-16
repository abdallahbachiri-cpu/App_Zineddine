import React, { useState, useEffect } from 'react';
import { 
  Card, 
  message, 
  Tabs,
  Space,
  Button,
  Form,
  Table,
  Input,
  Typography,
  Modal,
  Tag
} from 'antd';
import { useTranslation } from 'react-i18next';
import WalletBalance from './WalletBalance';
import TransactionsList from './TransactionsList';
import { 
  WalletDTO, 
  TransactionDTO,
  FoodStoreOption
} from '../../../types/adminWallet';
import API from '../../../services/api';
import { API_ENDPOINTS } from '../../../config/apiConfig';
 
const { TabPane } = Tabs;
const { Search } = Input;
const { Text } = Typography;

const AdminWallet: React.FC = () => {
  const { t } = useTranslation();
  const [form] = Form.useForm();
  const [selectedStoreId, setSelectedStoreId] = useState<string | null>(null);
  const [selectedStoreName, setSelectedStoreName] = useState<string>('');
  const [wallet, setWallet] = useState<WalletDTO | null>(null);
  const [transactions, setTransactions] = useState<TransactionDTO[]>([]);
  const [stores, setStores] = useState<FoodStoreOption[]>([]);
  const [filteredStores, setFilteredStores] = useState<FoodStoreOption[]>([]);
  const [loading, setLoading] = useState({
    stores: true,
    wallet: false,
    transactions: false,
    block: false,
    unblock: false,
  });
  const [dateRange] = useState<[string, string] | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  // Fetch all food stores
  useEffect(() => {
    const fetchStores = async () => {
      try {
        const response = await API.get(API_ENDPOINTS.ADMIN.FOOD_STORES);
        if (!response) throw new Error(t('adminWallet.fetchStoresError'));
        const data = await response.data.data;
        
        const storeOptions = data.map((store: any) => ({
          value: store.id,
          label: store.name,
        }));
        
        setStores(storeOptions);
        setFilteredStores(storeOptions);
      } catch (error: unknown) {
        if (error instanceof Error) {
          message.error(error.message);
        } else {
          message.error(t('common.unknownError'));
        }
      } finally {
        setLoading(prev => ({ ...prev, stores: false }));
      }
    };
    fetchStores();
  }, [t]);

  // Filter stores based on search query
  useEffect(() => {
    if (searchQuery) {
      const filtered = stores.filter(store =>
        store.label.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredStores(filtered);
    } else {
      setFilteredStores(stores);
    }
  }, [searchQuery, stores]);

  // Fetch wallet data when store is selected
  const fetchWallet = async (storeId: string) => {
    if (!storeId) return;
    
    try {
      setLoading(prev => ({ ...prev, wallet: true }));
      setWallet(null);
      
      const response = await API(`/admin/food-stores/${storeId}/wallet`);
      if (!response) throw new Error(t('adminWallet.fetchWalletError'));
      
      const data = await response.data;
      setWallet(data);
      
    } catch (error: unknown) {
      if (error instanceof Error) {
        message.error(error.message);
      } else {
        message.error(t('common.unknownError'));
      }
    } finally {
      setLoading(prev => ({ ...prev, wallet: false }));
    }
  };

  // Fetch transactions when store is selected or date range changes
  const fetchTransactions = async (storeId: string, range?: [string, string]) => {
    if (!storeId) return;
    
    try {
      setLoading(prev => ({ ...prev, transactions: true }));
      setTransactions([]);
      
      let url = API_ENDPOINTS.ADMIN.WALLET_TRANSACTIONS(storeId);
      if (range) {
        url += `?startDate=${range[0]}&endDate=${range[1]}`;
      }
      
      const response = await API.get(url);
      if (!response) throw new Error(t('adminWallet.fetchTransactionsError'));
      
      const data = await response.data;
      setTransactions(data);
    } catch (error: unknown) {
      if (error instanceof Error) {
        message.error(error.message);
      } else {
        message.error(t('common.unknownError'));
      }
    } finally {
      setLoading(prev => ({ ...prev, transactions: false }));
    }
  };

  const handleStoreSelect = (storeId: string, storeName: string) => {
    setSelectedStoreId(storeId);
    setSelectedStoreName(storeName);
    fetchWallet(storeId);
    fetchTransactions(storeId, dateRange || undefined);
  };


  const handleRefresh = () => {
    if (selectedStoreId) {
      fetchWallet(selectedStoreId);
      fetchTransactions(selectedStoreId, dateRange || undefined);
    }
  };

  const handleBlockWallet = () => {
    Modal.confirm({
      title: t('adminWallet.blockWallet'),
      content: t('adminWallet.blockWalletConfirm'),
      okText: t('common.ok'),
      cancelText: t('common.cancel'),
      onOk: async () => {
        if (!selectedStoreId) return;
        
        try {
          setLoading(prev => ({ ...prev, block: true }));
          
          const response = await API.post(API_ENDPOINTS.ADMIN.WALLET_BLOCK(selectedStoreId));
          if (!response) throw new Error(t('adminWallet.blockWalletError'));
          
          message.success(t('adminWallet.blockWalletSuccess'));
          
          // Refresh wallet data to get updated status
          await fetchWallet(selectedStoreId);
          
        } catch (error: unknown) {
          if (error instanceof Error) {
            message.error(error.message);
          } else {
            message.error(t('adminWallet.blockWalletError'));
          }
        } finally {
          setLoading(prev => ({ ...prev, block: false }));
        }
      },
    });
  };

  const handleUnblockWallet = () => {
    Modal.confirm({
      title: t('adminWallet.unblockWallet'),
      content: t('adminWallet.unblockWalletConfirm'),
      okText: t('common.ok'),
      cancelText: t('common.cancel'),
      onOk: async () => {
        if (!selectedStoreId) return;
        
        try {
          setLoading(prev => ({ ...prev, unblock: true }));
          
          const response = await API.post(API_ENDPOINTS.ADMIN.WALLET_UNBLOCK(selectedStoreId));
          if (!response) throw new Error(t('adminWallet.unblockWalletError'));
          
          message.success(t('adminWallet.unblockWalletSuccess'));
          
          // Refresh wallet data to get updated status
          await fetchWallet(selectedStoreId);
          
        } catch (error: unknown) {
          if (error instanceof Error) {
            message.error(error.message);
          } else {
            message.error(t('adminWallet.unblockWalletError'));
          }
        } finally {
          setLoading(prev => ({ ...prev, unblock: false }));
        }
      },
    });
  };

  const storeColumns = [
    {
      title: t('adminWallet.storeName'),
      dataIndex: 'label',
      key: 'label',
    },
    {
      title: t('adminWallet.actions'),
      key: 'actions',
      render: (_: any, record: FoodStoreOption) => (
        <Button 
          type="primary"
          onClick={() => handleStoreSelect(record.value, record.label)}
          disabled={selectedStoreId === record.value}
        >
          {selectedStoreId === record.value ? t('adminWallet.selected') : t('adminWallet.select')}
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <Card title={t('adminWallet.title')}>
        <Space direction="vertical" size="large" style={{ width: '100%' }}>
          <div>
            <Search
              placeholder={t('adminWallet.searchStorePlaceholder')}
              allowClear
              enterButton
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{ marginBottom: 16, width: 300 }}
            />
            <Table
              columns={storeColumns}
              dataSource={filteredStores}
              rowKey="value"
              loading={loading.stores}
              pagination={{
                pageSize: 5,
                showSizeChanger: false,
              }}
              locale={{
                emptyText: t('adminWallet.noStoresFound')
              }}
            />
          </div>

          {selectedStoreId && (
            <>
              <Text strong>
                {t('adminWallet.selectedStore')}: {selectedStoreName}
              </Text>
              <Tabs defaultActiveKey="1">
                <TabPane tab={t('adminWallet.overviewTab')} key="1">
                  <Space direction="vertical" size="middle" style={{ width: '100%' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
                      <div>
                        <Text strong>{t('adminWallet.walletStatus')}: </Text>
                        <Tag color={wallet?.isActive ? 'green' : 'red'}>
                          {wallet?.isActive ? t('adminWallet.active') : t('adminWallet.blocked')}
                        </Tag>
                      </div>
                      <Space>
                        {wallet?.isActive ? (
                          <Button 
                            danger
                            onClick={handleBlockWallet}
                            loading={loading.block}
                          >
                            {t('adminWallet.blockWallet')}
                          </Button>
                          
                        ) : (
                          <Button 
                            type="primary"
                            onClick={handleUnblockWallet}
                            loading={loading.unblock}
                          >
                            {t('adminWallet.unblockWallet')}
                          </Button>
                        )}
                      </Space>
                    </div>
                    <WalletBalance 
                      wallet={wallet!} 
                      loading={loading.wallet} 
                    />
                  </Space>
                </TabPane>
                <TabPane tab={t('adminWallet.transactionsTab')} key="2">
                  <Space direction="vertical" size="middle" style={{ width: '100%' }}>
                    <Form form={form} layout="inline">
                      <Form.Item>
                        <Button 
                          onClick={handleRefresh}
                          loading={loading.transactions}
                        >
                          {t('adminWallet.refresh')}
                        </Button>
                      </Form.Item>
                    </Form>
                    <TransactionsList 
                      transactions={transactions} 
                      loading={loading.transactions}
                    />
                  </Space>
                </TabPane>
              </Tabs>
            </>
          )}

          {!selectedStoreId && !loading.stores && (
            <Card>
              <Text>{t('adminWallet.selectStorePrompt')}</Text>
            </Card>
          )}
        </Space>
      </Card>
    </div>
  );
};

export default AdminWallet;