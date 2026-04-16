// Resources/Private/TypeScript/Admin/Wallet/TransactionsList.tsx
import React from 'react';
import { Table, Tag } from 'antd';
import { useTranslation } from 'react-i18next';
import { TransactionDTO } from '../../../types/wallet';
import type { ColumnsType } from 'antd/es/table';

interface TransactionsListProps {
  transactions: TransactionDTO[];
  loading: boolean;
}

const TransactionsList: React.FC<TransactionsListProps> = ({ transactions, loading }) => {
  const { t } = useTranslation();

  const columns: ColumnsType<TransactionDTO> = [
    {
      title: t("wallet.transaction.date"),
      dataIndex: "createdAt",
      key: "createdAt",
      render: (date) => new Date(date).toLocaleString(),
      sorter: (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
    },
    {
      title: t("wallet.transaction.description"),
      dataIndex: "description",
      key: "description",
    },
    {
      title: t("wallet.transaction.grossAmount"),
      dataIndex: "grossAmount",
      key: "grossAmount",
    },
    {
      title: t("wallet.transaction.commissionAmount"),
      dataIndex: "commissionAmount",
      key: "commissionAmount",
    },
    {
      title: t("wallet.transaction.commissionRate"),
      dataIndex: "commissionRate",
      key: "commissionRate",
    },
    {
      title: t("wallet.transaction.amount"),
      dataIndex: "amount",
      key: "amount",
      render: (amount: number, record) => (
        <span style={{ color: record.type === "withdrawal" ? "red" : "green" }}>
          {record.type === "withdrawal" ? "-" : "+"}
          {amount}
        </span>
      ),
      sorter: (a, b) => a.amount - b.amount,
    },
    {
      title: t("wallet.transaction.status"),
      dataIndex: "status",
      key: "status",
      render: (status) => (
        <Tag color={status === "completed" ? "green" : status === "pending" ? "orange" : "red"}>
          {t(`wallet.status.${status}`)}
        </Tag>
      ),
      filters: [
        { text: "Completed", value: "completed" },
        { text: "Pending", value: "pending" },
        { text: "Failed", value: "failed" },
      ],
      onFilter: (value, record) => record.status === value,
    },
    {
      title: t("wallet.transaction.type"),
      dataIndex: "type",
      key: "type",
      render: (type) => (
        <Tag color={type === "credit" ? "green" : "red"}>
          {t(`wallet.type.${type}`)}
        </Tag>
      ),
      filters: [
        { text: "Credit", value: "credit" },
        { text: "Debit", value: "debit" },
      ],
      onFilter: (value, record) => record.type === value,
    },
  ];

  return (
    <Table
      columns={columns}
      dataSource={transactions}
      rowKey="id"
      loading={loading}
      pagination={{ pageSize: 10 }}
      scroll={{ x: true }}
    />
  );
};

export default TransactionsList;