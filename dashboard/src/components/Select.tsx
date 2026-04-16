import React from "react";

interface SelectProps {
  label?: string;
  value: string;
  onChange: (event: React.ChangeEvent<HTMLSelectElement>) => void;
  options: string[];
}

const Select: React.FC<SelectProps> = ({ label, value, onChange, options }) => {
  return (
    <div className="flex flex-col mb-4 mt-2">
      {label && <label className='block mb-2 font-bold'>{label}</label>}
      <select
        className="p-2 border rounded-md bg-white cursor-pointer"
        value={value}
        onChange={onChange}
      >
        {options.map((option, index) => (
          <option key={index} value={option}>
            {option}
          </option>
        ))}
      </select>
    </div>
  );
};

export default Select;
