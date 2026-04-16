import React, { useState } from "react";
import Button from "../../components/Button/Button";
import Input from "../../components/Input";
import GoogleIcon from "../../assets/GoogleIcon.svg";

const Security: React.FC = () => {
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const handlePasswordUpdate = () => {
    if (newPassword !== confirmPassword) {
      alert("Passwords do not match!");
      return;
    }
    alert("Password updated successfully!");
  };

  return (
    <div className="p-8 bg-white min-h-screen">
      <h1 className="text-3xl font-semibold mb-8">Account Security</h1>

      {/* Account Linking Section */}
      <div className="mb-8">
        <h2 className="text-xl font-semibold mb-4">
          Your Account is linked to:
        </h2>
        <button className="flex items-center gap-2 p-2 bg-gray-100 border rounded-md">
          <img src={GoogleIcon} alt="Contact" className="icon w-10 h-10" />
          <span className="text-base pr-2">Linked with Google</span>
        </button>
      </div>

      {/* Update Account Credentials */}
      <div className="flex flex-col">
        <h2 className="text-xl font-semibold mb-4">
          Update your account Credentials
        </h2>
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="Password"
            type="password"
            placeholder="Create new Password"
            value={newPassword}
            onChange={(e: any) => setNewPassword(e.target.value)}
          />
          <Input
            label="Password"
            type="password"
            placeholder="Re-enter Password"
            value={confirmPassword}
            onChange={(e: any) => setConfirmPassword(e.target.value)}
          />
        </div>
        <Button
          label="Save"
          onClick={handlePasswordUpdate}
          className="mt-4 ml-auto text-[white] bg-[#36B44A] pl-[4.5rem] pr-[4.5rem] py-[8px] rounded-[10px]"
        />
      </div>
    </div>
  );
};

export default Security;
