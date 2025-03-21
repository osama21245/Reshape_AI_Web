import { motion } from "framer-motion";
import { ArrowRight, ArrowLeft } from "lucide-react";

interface CustomizationStepProps {
    value: string;
    onChange: (value: string) => void;
    onSubmit: () => void;
    onBack: () => void;
}

export function CustomizationStep({ value, onChange, onSubmit, onBack }: CustomizationStepProps) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
        >
            <div className="text-center space-y-4">
                <h2 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                    Additional Requirements
                </h2>
                <p className="text-gray-400">Tell us more about your vision</p>
            </div>
            <div className="max-w-2xl mx-auto space-y-6">
                <textarea
                    value={value}
                    onChange={(e) => onChange(e.target.value)}
                    placeholder="E.g., Add more plants, Include hidden LED lighting, Make it cozy..."
                    className="w-full h-32 bg-white/5 backdrop-blur-sm rounded-xl border border-white/10 p-4 focus:border-purple-500/50 focus:outline-none transition-colors"
                />
                <div className="flex justify-between gap-4">
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
                        Next
                        <ArrowRight className="w-5 h-5" />
                    </motion.button>
                </div>
            </div>
        </motion.div>
    );
} 