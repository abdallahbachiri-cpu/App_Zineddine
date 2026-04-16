// Resources/Private/TypeScript/Wallet/TransactionsList.tsx
import React from "react";
import { Table, Tag } from "antd";
import { TransactionDTO } from "../../types/wallet";
import type { ColumnsType } from "antd/es/table";
import { useTranslation } from "react-i18next";

interface TransactionsListProps {
  transactions: TransactionDTO[];
  loading: boolean;
}

const TransactionsList: React.FC<TransactionsListProps> = ({
  transactions,
  loading,
}) => {
  const { t } = useTranslation();

  const columns: ColumnsType<TransactionDTO> = [
    {
      title: t("wallet.transaction.date"),
      dataIndex: "createdAt",
      key: "createdAt",
      render: (date) => new Date(date).toLocaleDateString(),
    },
    {
      title: t("wallet.transaction.type"),
      dataIndex: "type",
      key: "type",
      render: (type) => t(`wallet.type.${type}`),
    },
    {
      title: t("wallet.transaction.currency"),
      dataIndex: "currency",
      key: "currency",
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
    },
    {
      title: t("wallet.transaction.grossAmount"),
      dataIndex: "grossAmount",
      key: "grossAmount"
    },
    {
      title: t("wallet.transaction.commissionAmount"),
      dataIndex: "commissionAmount",
      key: "commissionAmount"
    },
    {
      title: t("wallet.transaction.commissionRate"),
      dataIndex: "commissionRate",
      key: "commissionRate"
    },
    {
      title: t("wallet.transaction.status"),
      dataIndex: "status",
      key: "status",
      render: (status) => (
        <Tag
          color={
            status === "completed"
              ? "green"
              : status === "pending"
                ? "orange"
                : "red"
          }
        >
          {t(`wallet.status.${status}`)}
        </Tag>
      ),
    },
    {
      title: t("wallet.transaction.description"),
      dataIndex: "description",
      key: "description",
    },
  ];

  return (
    <Table
      columns={columns}
      dataSource={transactions}
      rowKey="id"
      loading={loading}
      pagination={{ pageSize: 10 }}
    />
  );
};

export default TransactionsList;