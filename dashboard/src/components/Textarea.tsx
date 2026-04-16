import React from "react";

interface TextareaProps {
  label: string;  
  name: string;
  value: string;
  onChange: (event: React.ChangeEvent<HTMLTextAreaElement>) => void;
  placeholder?: string;
  rows?: number;
  className?: string;
  required?: boolean;
}

const Textarea: React.FC<TextareaProps> = ({
  label,
  name,
  value,
  onChange,
  placeholder,
  rows = 4,
  className = "",
  required,
  ...props
}) => {
  return (
    <div className='mb-4 mt-2'>
      <label className='block mb-2 font-bold'>
        {label}
      </label>
    <textarea
      {...props}
      name={name}
      value={value}
      onChange={onChange}
      placeholder={placeholder}
      rows={rows}
      className={`border border-gray-300 rounded-lg p-2 w-full focus:ring-2 focus:ring-green-500 outline-none ${className}`}
    />
    </div>
  );
};

export default Textarea;
