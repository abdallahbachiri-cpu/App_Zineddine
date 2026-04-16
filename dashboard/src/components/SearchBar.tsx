import React, { useState, useEffect, useCallback } from "react";
import { debounce } from "../utils/debounce";

interface SearchBarProps {
  searchValue: string;
  onSearchChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  filterOptions?: {
    value: string;
    onChange: (value: string) => void;
    options: { value: string; label: string }[];
  };
  sortOptions?: {
    value: string;
    onChange: (value: string) => void;
    options: { value: string; label: string }[];
  };
  debounceDelay?: number;
}

const SearchBar: React.FC<SearchBarProps> = ({
  searchValue: initialValue,
  onSearchChange,
  placeholder = "Search...",
  className = "",
  filterOptions,
  sortOptions,
  debounceDelay = 300,
}) => {
  const [localSearchValue, setLocalSearchValue] = useState(initialValue);

  // Debounce the external onSearchChange
  const debouncedOnSearchChange = useCallback(
    debounce((value: string) => {
      onSearchChange(value);
    }, debounceDelay),
    [onSearchChange, debounceDelay]
  );

  // Update local state when props change
  useEffect(() => {
    setLocalSearchValue(initialValue);
  }, [initialValue]);

  // Handle input changes with debounce
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setLocalSearchValue(value);
    debouncedOnSearchChange(value);
  };

  // Handle filter changes
  const handleFilterChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    filterOptions?.onChange(e.target.value);
  };

  // Handle sort changes
  const handleSortChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    sortOptions?.onChange(e.target.value);
  };

  return (
    <div className={`bg-white p-4 rounded-lg shadow ${className}`}>
      <div className="flex flex-col md:flex-row md:items-center md:space-x-4 space-y-4 md:space-y-0">
        <div className="relative flex-grow">
          <input
            type="text"
            placeholder={placeholder}
            value={localSearchValue}
            onChange={handleInputChange}
            className="pl-4 w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        {(filterOptions || sortOptions) && (
          <div className="flex space-x-2">
            {filterOptions && (
              <select
                value={filterOptions.value}
                onChange={handleFilterChange}
                className="px-4 py-2 border border-gray-300 rounded-md"
              >
                {filterOptions.options.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            )}

            {sortOptions && (
              <select
                value={sortOptions.value}
                onChange={handleSortChange}
                className="px-4 py-2 border border-gray-300 rounded-md"
              >
                {sortOptions.options.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default SearchBar;