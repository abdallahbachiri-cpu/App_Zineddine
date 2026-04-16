import React from 'react';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  label: string;
  onClick: () => void;
}

const Button: React.FC<ButtonProps> = ({ label, onClick, className, ...props }) => (
  <button 
    onClick={onClick} 
    className={className}
    {...props}
  >
    {label}
  </button>
);

export default Button;