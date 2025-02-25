"use client";
import { motion } from "framer-motion";
import ReactBeforeSliderComponent from 'react-before-after-slider-component';
import 'react-before-after-slider-component/dist/build.css';
import { useEffect, useState } from 'react';
import { X, Download, Share2 } from 'lucide-react';
import { useRouter } from 'next/navigation';

interface BeforeAfterSliderProps {
    beforeImage: string;
    afterImage: string;
    onClose: () => void;
    imageId?: number;
}

export function BeforeAfterSlider({ beforeImage, afterImage, onClose, imageId }: BeforeAfterSliderProps) {
    const [mounted, setMounted] = useState(false);
    const router = useRouter();

    useEffect(() => {
        setMounted(true);
    }, []);

    const handleClose = () => {
        onClose();
        router.push('/dashboard');
    };

    const handleDownload = async () => {
        try {
            const response = await fetch('/api/download-image', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ imageUrl: afterImage })
            });

            if (!response.ok) throw new Error('Download failed');

            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `ai-room-transformation-${Date.now()}.png`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            window.URL.revokeObjectURL(url);
        } catch (error) {
            console.error('Error downloading image:', error);
        }
    };

    const handleShare = async () => {
        try {
            if (navigator.share) {
                await navigator.share({
                    title: 'My AI Room Transformation',
                    text: 'Check out my room transformation using Reshape AI!',
                    url: `${window.location.origin}/share/${imageId}`
                });
            } else {
                await navigator.clipboard.writeText(
                    `${window.location.origin}/share/${imageId}`
                );
                alert('Share link copied to clipboard!');
            }
        } catch (error) {
            console.error('Error sharing:', error);
        }
    };

    if (!mounted) return null;

    return (
        <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/90 backdrop-blur-xl z-50 flex items-center justify-center p-4"
        >
            <div className="relative max-w-xl w-full space-y-4">
                {/* Header */}
                <div className="flex items-center justify-between">
                    <div>
                        <h2 className="text-lg font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                            Your AI Transformation
                        </h2>
                        <p className="text-xs text-gray-400 mt-1">
                            Drag the slider to compare before and after
                        </p>
                    </div>
                    <motion.button
                        onClick={handleClose}
                        className="p-1.5 bg-white/5 backdrop-blur-sm rounded-full hover:bg-white/10 transition-colors"
                        whileHover={{ scale: 1.1 }}
                        whileTap={{ scale: 0.9 }}
                    >
                        <X className="w-4 h-4" />
                    </motion.button>
                </div>

                {/* Slider Container */}
                <div className="relative w-full rounded-xl overflow-hidden border border-white/10 bg-white/5 backdrop-blur-sm">
                    <div className="max-w-[900px] mx-auto">
                        <ReactBeforeSliderComponent
                            firstImage={{ imageUrl: beforeImage }}
                            secondImage={{ imageUrl: afterImage }}
                            delimiterColor="rgb(139, 92, 246)"
                            className="w-full"
                        />
                    </div>
                </div>

                {/* Action Buttons */}
                <div className="flex justify-center gap-3">
                    <motion.button
                        onClick={handleDownload}
                        className="px-4 py-2 bg-white/5 backdrop-blur-sm rounded-lg text-sm font-medium flex items-center gap-1.5 hover:bg-white/10 transition-colors"
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                    >
                        <Download className="w-4 h-4" />
                        Download
                    </motion.button>
                    <motion.button
                        onClick={handleShare}
                        className="px-4 py-2 bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg text-sm font-medium flex items-center gap-1.5 hover:opacity-90 transition-opacity"
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                    >
                        <Share2 className="w-4 h-4" />
                        Share Result
                    </motion.button>
                </div>
            </div>
        </motion.div>
    );
} 