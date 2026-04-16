import React from "react";
import PayoutConfiguration from "../PayoutConfiguration";
import { useTranslation } from 'react-i18next';


const SettingsPage: React.FC = () => {
  const { t } = useTranslation();


  return (
    <div className="p-6 flex flex-col">
      <h1 className="text-2xl font-bold mb-4">{t('settings.title')}</h1>
        <PayoutConfiguration/>
    </div>
  );
};

export default SettingsPage;
