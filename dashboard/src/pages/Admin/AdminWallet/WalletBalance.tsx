// Resources/Private/TypeScript/Admin/Wallet/WalletBalance.tsx
import React from 'react';
import { Card, Statistic } from 'antd';
import { WalletDTO } from '../../../types/wallet';
import { useTranslation } from 'react-i18next';
interface WalletBalanceProps {
  wallet: WalletDTO;
  loading: boolean;
}

const WalletBalance: React.FC<WalletBalanceProps> = ({ wallet, loading }) => {
  const { t } = useTranslation();  
  return (
    wallet && (
    <Card 
      title={t("wallet.title")}
      loading={loading}
    >
      <Statistic
        title={t("wallet.balance.availableBalance")}
        value={wallet.availableBalance}
        precision={2}
        valueStyle={{ color: '#3f8600' }}
        suffix={wallet.currency}
      />
    </Card>
    )
  );
};
export default WalletBalance;