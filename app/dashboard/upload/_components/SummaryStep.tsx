import { motion } from "framer-motion";
import { Sparkles, ArrowRight, ArrowLeft } from "lucide-react";
import Image from "next/image";

interface SummaryStepProps {
    imageUrl: string;
    roomType: string;
    style: string;
    customization: string;
    onBack: () => void;
    onSubmit: () => void;
}

export function SummaryStep({ 
    imageUrl, 
    roomType, 
    style, 
    customization,
    onBack,
    onSubmit 
}: SummaryStepProps) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
        >
            <div className="text-center space-y-4">
                <h2 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                    Review Your Choices
                </h2>
                <p className="text-gray-400">Confirm your transformation details</p>
            </div>

            <div className="max-w-2xl mx-auto space-y-6 bg-white/5 backdrop-blur-sm rounded-2xl p-6 border border-white/10">
                <div className="space-y-6">
                    <div className="space-y-2">
                        <h3 className="text-sm text-gray-400">Selected Image</h3>
                        <div className="relative h-48 rounded-xl overflow-hidden">
                            <Image
                                src={imageUrl}
                                alt="Selected room"
                                fill
                                className="object-cover"
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <h3 className="text-sm text-gray-400">Room Type</h3>
                            <p className="text-lg font-medium">{roomType}</p>
                        </div>
                        <div className="space-y-2">
                            <h3 className="text-sm text-gray-400">Style</h3>
                            <p className="text-lg font-medium">{style}</p>
                        </div>
                    </div>

                    {customization && (
                        <div className="space-y-2">
                            <h3 className="text-sm text-gray-400">Additional Requirements</h3>
                            <p className="text-gray-200">{customization}</p>
                        </div>
                    )}
                </div>
            </div>

            <div className="flex justify-between gap-4 max-w-2xl mx-auto">
                <motion.button
                    onClick={onBack}
                    className="px-6 py-4 bg-white/5 backdrop-blur-sm rounded-xl font-medium flex items-center gap-2 hover:bg-white/10 transition-colors"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                >
                    <ArrowLeft className="w-5 h-5" />
                    Back
                </motion.button>

                <motion.button
                    onClick={onSubmit}
                    className="flex-1 py-4 bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl font-medium flex items-center justify-center gap-2 hover:opacity-90 transition-opacity"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                >
                    <Sparkles className="w-5 h-5" />
                    Generate AI Room
                    <ArrowRight className="w-5 h-5" />
                </motion.button>
            </div>
        </motion.div>
    );
} 