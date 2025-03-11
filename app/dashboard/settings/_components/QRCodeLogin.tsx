"use client";
import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { QRCodeSVG } from "qrcode.react";
import { Smartphone, RefreshCw, AlertCircle } from "lucide-react";
import toast from 'react-hot-toast';

export default function QRCodeLogin() {
  const [qrData, setQrData] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [expiresAt, setExpiresAt] = useState<Date | null>(null);
  const [timeLeft, setTimeLeft] = useState<number>(0);

  // Function to generate a new QR code
  const generateQRCode = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const response = await fetch("/api/auth/generate-qr-token", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        const errorData = await response.json();
        console.error("QR code generation error:", errorData);
        throw new Error(errorData.error || "Failed to generate QR code");
      }

      const data = await response.json();
      
      // Create QR data with token and user ID
      const qrCodeData = JSON.stringify({
        token: data.token,
        userId: data.userId,
        expiresAt: data.expiresAt,
        appId: "reshape-ai-mobile", // Identifier for your mobile app
      });
      
      setQrData(qrCodeData);
      setExpiresAt(new Date(data.expiresAt));
      toast.success("QR code generated successfully");
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : "An error occurred";
      setError(errorMessage);
      console.error("Error generating QR code:", err);
      toast.error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  // Generate QR code on component mount
  useEffect(() => {
    generateQRCode();
  }, []);

  // Update time left
  useEffect(() => {
    if (!expiresAt) return;

    const interval = setInterval(() => {
      const now = new Date();
      const diff = expiresAt.getTime() - now.getTime();
      
      if (diff <= 0) {
        setTimeLeft(0);
        setQrData(null);
        clearInterval(interval);
      } else {
        setTimeLeft(Math.floor(diff / 1000));
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [expiresAt]);

  // Format time left as MM:SS
  const formatTimeLeft = () => {
    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    return `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h3 className="text-xl font-semibold">Mobile App Login</h3>
        <motion.button
          onClick={generateQRCode}
          disabled={isLoading}
          className="flex items-center gap-2 px-3 py-2 bg-white/10 rounded-lg hover:bg-white/20 transition-colors disabled:opacity-50"
          whileHover={{ scale: isLoading ? 1 : 1.05 }}
          whileTap={{ scale: isLoading ? 1 : 0.95 }}
        >
          <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          {isLoading ? 'Generating...' : 'Refresh'}
        </motion.button>
      </div>

      <div className="bg-white/5 backdrop-blur-sm rounded-xl border border-white/10 p-6">
        <div className="flex flex-col items-center gap-6">
          <div className="flex items-center gap-2 text-sm text-gray-400">
            <Smartphone className="w-4 h-4" />
            <span>Scan with your mobile app to log in</span>
          </div>

          {isLoading ? (
            <div className="w-48 h-48 bg-white/5 rounded-lg flex items-center justify-center">
              <div className="w-8 h-8 border-2 border-purple-500 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : error ? (
            <div className="w-48 h-48 bg-white/5 rounded-lg flex flex-col items-center justify-center text-center p-4 gap-4">
              <AlertCircle className="w-8 h-8 text-red-400" />
              <p className="text-red-400 text-sm">{error}</p>
              <motion.button
                onClick={generateQRCode}
                className="px-3 py-1 bg-white/10 rounded-lg text-sm hover:bg-white/20 transition-colors"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                Try Again
              </motion.button>
            </div>
          ) : qrData ? (
            <div className="p-4 bg-white rounded-lg">
              <QRCodeSVG
                value={qrData}
                size={200}
                level="H"
                includeMargin={true}
                bgColor="#FFFFFF"
                fgColor="#000000"
              />
            </div>
          ) : (
            <div className="w-48 h-48 bg-white/5 rounded-lg flex flex-col items-center justify-center gap-4">
              <p className="text-gray-400 text-sm">QR code expired</p>
              <motion.button
                onClick={generateQRCode}
                className="px-3 py-1 bg-white/10 rounded-lg text-sm hover:bg-white/20 transition-colors"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                Generate New Code
              </motion.button>
            </div>
          )}

          {qrData && timeLeft > 0 && (
            <div className="text-sm text-gray-400">
              Expires in <span className="text-purple-400 font-mono">{formatTimeLeft()}</span>
            </div>
          )}

          <p className="text-xs text-gray-500 text-center max-w-xs">
            Scanning this QR code will allow you to log in to the Reshape AI mobile app without entering your password.
          </p>
        </div>
      </div>
    </div>
  );
} 