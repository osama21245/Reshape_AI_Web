import { motion } from "framer-motion";

interface StepProgressProps {
    currentStep: number;
    totalSteps: number;
}

export function StepProgress({ currentStep, totalSteps }: StepProgressProps) {
    return (
        <div className="flex justify-center gap-4 mb-12">
            {[...Array(totalSteps)].map((_, i) => (
                <motion.div
                    key={i}
                    className={`w-3 h-3 rounded-full ${
                        i + 1 <= currentStep ? 'bg-purple-500' : 'bg-gray-600'
                    }`}
                    initial={{ scale: 0.8 }}
                    animate={{ scale: i + 1 === currentStep ? 1.2 : 1 }}
                    transition={{ duration: 0.5, repeat: i + 1 === currentStep ? Infinity : 0, repeatType: "reverse" }}
                />
            ))}
        </div>
    );
} 