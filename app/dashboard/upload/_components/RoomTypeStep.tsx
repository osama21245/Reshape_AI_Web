import { motion } from "framer-motion";
import { ArrowLeft } from "lucide-react";

const roomTypes = [
    { id: 'bedroom', label: 'Bedroom', icon: '🛏️' },
    { id: 'bathroom', label: 'Bathroom', icon: '🚿' },
    { id: 'living-room', label: 'Living Room', icon: '🛋️' },
    { id: 'kitchen', label: 'Kitchen', icon: '🍳' },
    { id: 'office', label: 'Office', icon: '💼' },
    { id: 'gaming-room', label: 'Gaming Room', icon: '🎮' },
];

interface RoomTypeStepProps {
    onSelect: (roomType: string) => void;
    onBack: () => void;
}

export function RoomTypeStep({ onSelect, onBack }: RoomTypeStepProps) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
        >
            <div className="text-center">
                <h2 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                    Select Room Type
                </h2>
            </div>
            <div className="max-w-6xl mx-auto space-y-6">
                <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                    {roomTypes.map((type) => (
                        <motion.button
                            key={type.id}
                            onClick={() => onSelect(type.id)}
                            className="group relative p-6 rounded-2xl bg-white/5 backdrop-blur-sm border border-white/10 hover:border-purple-500/50 transition-all duration-300"
                            whileHover={{ scale: 1.02 }}
                        >
                            <div className="text-4xl mb-4">{type.icon}</div>
                            <div className="text-lg font-medium">{type.label}</div>
                        </motion.button>
                    ))}
                </div>
                <motion.button
                    onClick={onBack}
                    className="px-6 py-4 bg-white/5 backdrop-blur-sm rounded-xl font-medium flex items-center gap-2 hover:bg-white/10 transition-colors"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                >
                    <ArrowLeft className="w-5 h-5" />
                    Back
                </motion.button>
            </div>
        </motion.div>
    );
} 