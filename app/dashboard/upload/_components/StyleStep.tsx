import { motion } from "framer-motion";
import { ArrowLeft, ArrowRight, Sparkles, Factory, Palette, Crown, Trees, Minimize2 } from "lucide-react";

const designStyles = [
    { 
        id: 'modern',
        label: 'Modern',
        description: 'Sleek, futuristic, high-tech',
        icon: Sparkles,
        gradient: 'from-blue-500 to-purple-500',
        accent: 'bg-blue-500/20'
    },
    { 
        id: 'industrial',
        label: 'Industrial',
        description: 'Raw, urban, metallic',
        icon: Factory,
        gradient: 'from-gray-500 to-zinc-700',
        accent: 'bg-gray-500/20'
    },
    { 
        id: 'bohemian',
        label: 'Bohemian',
        description: 'Vibrant, eclectic, artistic',
        icon: Palette,
        gradient: 'from-orange-500 to-pink-500',
        accent: 'bg-orange-500/20'
    },
    { 
        id: 'traditional',
        label: 'Traditional',
        description: 'Classic, timeless, elegant',
        icon: Crown,
        gradient: 'from-amber-500 to-red-500',
        accent: 'bg-amber-500/20'
    },
    { 
        id: 'rustic',
        label: 'Rustic',
        description: 'Warm, nature-inspired',
        icon: Trees,
        gradient: 'from-green-500 to-emerald-700',
        accent: 'bg-green-500/20'
    },
    { 
        id: 'minimalist',
        label: 'Minimalist',
        description: 'Clean, simple, elegant',
        icon: Minimize2,
        gradient: 'from-neutral-300 to-neutral-500',
        accent: 'bg-neutral-500/20'
    },
];

interface StyleStepProps {
    onSelect: (style: string) => void;
    onBack: () => void;
}

export function StyleStep({ onSelect, onBack }: StyleStepProps) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-8"
        >
            <div className="text-center">
                <h2 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                    Choose Your Style
                </h2>
            </div>
            <div className="max-w-6xl mx-auto space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {designStyles.map((style) => (
                        <motion.button
                            key={style.id}
                            onClick={() => onSelect(style.id)}
                            className="group relative overflow-hidden rounded-2xl border border-white/10 bg-white/5 backdrop-blur-sm"
                            whileHover={{ scale: 1.02 }}
                        >
                            <div className={`absolute inset-0 bg-gradient-to-br ${style.gradient} opacity-0 group-hover:opacity-10 transition-opacity duration-300`} />
                            
                            <div className="relative p-6 space-y-4">
                                <div className={`w-12 h-12 rounded-xl ${style.accent} flex items-center justify-center`}>
                                    <style.icon className="w-6 h-6" />
                                </div>
                                
                                <div className="space-y-2 text-left">
                                    <h3 className="text-xl font-semibold">{style.label}</h3>
                                    <p className="text-sm text-gray-400">{style.description}</p>
                                </div>

                                <div className="absolute bottom-0 right-0 p-4 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <div className={`w-8 h-8 rounded-full ${style.accent} flex items-center justify-center`}>
                                        <ArrowRight className="w-4 h-4" />
                                    </div>
                                </div>
                            </div>
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