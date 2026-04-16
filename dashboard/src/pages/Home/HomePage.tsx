import React from "react";
import "ag-grid-community/styles/ag-grid.css";
import "ag-grid-community/styles/ag-theme-alpine.css";
import Users from "../Users/Users";
const HomePage: React.FC = () => {

  return (
      <div className="ag-theme-alpine" style={{ height: 300, width: "100%" }}>
        <Users />
      </div>
  );
};

export default HomePage;
