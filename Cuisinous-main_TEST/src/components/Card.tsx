import React from "react";

interface CardProps {
  title: string;
  icon: string;
  total: number;
  description: string;
}

const Card: React.FC<CardProps> = ({ title, icon, total, description }) => {
  return (
    <div className="bg-white p-4 rounded-xl shadow-md inline-flex flex-col items-center justify-between w-full">
      <div className="flex">
        <div className="mr-4 flex flex-col gap-6">
          <p className="text-gray-500 whitespace-nowrap">{title}</p>
          <h2 className="font-medium text-[1.5rem]">
            ${total.toLocaleString()}
          </h2>
        </div>
        <div className="rounded-[25px] p-[15px]">
          <img src={icon} alt="" />
        </div>
      </div>
      {description && (
        <p className={`text-sm mt-2 whitespace-nowrap ${description}`}>{description}</p>
      )}
    </div>
  );
};

export default Card;
