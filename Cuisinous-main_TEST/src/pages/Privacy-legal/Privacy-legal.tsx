import React, { useEffect, useState } from "react";
import Button from "../../components/Button/Button";

const PrivacyLegal: React.FC = () => {
  const [isAccepted, setIsAccepted] = useState<boolean>(false);

  // Check acceptance state on initial render
  useEffect(() => {
    const storedAcceptance = localStorage.getItem("privacyAccepted");
    setIsAccepted(storedAcceptance === "true");
  }, []);

  // Handle button click to accept the privacy policy
  const handleAccept = () => {
    setIsAccepted(true);
    localStorage.setItem("privacyAccepted", "true");
  };

  return (
    <div className="p-8 bg-white min-h-screen">
      <h1 className="text-3xl font-semibold mb-2">Privacy Policy & Legal</h1>
      <p className="text-gray-500 mb-6">Effective Date: 2025/01/01</p>

      <p className="mb-4">
        Welcome to cuisious! Your privacy is important to us. This Privacy Policy outlines how we collect, use, and safeguard your personal information.
      </p>

      {/* Render the content only if not accepted */}
      {!isAccepted ? (
        <>
          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-2">1. Information We Collect</h2>
            <ul className="list-disc list-inside">
              <li>Personal Information: Name, email address, phone number, delivery address, and payment details.</li>
              <li>Usage Data: App activity, preferences, and interactions to improve your experience.</li>
              <li>Location Information: For providing location-based services such as nearby restaurants or delivery tracking.</li>
            </ul>
          </section>

          <div className="flex justify-end mt-4">
            <Button 
              className="text-white bg-green-500 px-6 py-2 rounded-lg ml-auto pl-[4.5rem] pr-[4.5rem]"
              label="Agree" 
              onClick={handleAccept}/>
          </div>
        </>
      ) : (
        <p className="text-green-700 text-lg">Thank you for accepting the Privacy Policy!</p>
      )}
    </div>
  );
};

export default PrivacyLegal;
