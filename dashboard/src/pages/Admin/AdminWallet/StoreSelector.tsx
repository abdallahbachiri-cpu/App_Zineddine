// Resources/Private/TypeScript/Admin/Wallet/StoreSelector.tsx
import React from 'react';
import { Select, Form } from 'antd';
import { FoodStoreOption } from '../../../types/wallet';
const { Option } = Select;

interface StoreSelectorProps {
  stores: FoodStoreOption[];
  loading: boolean;
  onSelect: (storeId: string) => void;
  initialValue?: string;
}

const StoreSelector: React.FC<StoreSelectorProps> = ({ 
  stores, 
  loading, 
  onSelect,
  initialValue 
}) => {
  return (
    <Form.Item label="Select Food Store" required>
      <Select
        showSearch
        placeholder="Search food store"
        optionFilterProp="children"
        onChange={onSelect}
        loading={loading}
        style={{ width: 300 }}
        defaultValue={initialValue}
        filterOption={(input, option) =>
          (option?.label?.toString() ?? '').toLowerCase().includes(input.toLowerCase())
        }
      >
        {stores.map(store => (
          <Option key={store.value} value={store.value}>
            {store.label}
          </Option>
        ))}
      </Select>
    </Form.Item>
  );
};

export default StoreSelector;