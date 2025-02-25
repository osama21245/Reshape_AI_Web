import { motion } from "framer-motion";
import { Upload, Sparkles } from "lucide-react";

interface UploadStepProps {
    onImageUpload: (file: File) => void;
}

export function UploadStep({ onImageUpload }: UploadStepProps) {
    const handleDrop = (e: React.DragEvent) => {
        e.preventDefault();
        const file = e.dataTransfer.files[0];
        if (file && file.type.startsWith('image/')) {
            onImageUpload(file);
        }
    };

    const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            onImageUpload(file);
        }
    };

    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="relative"
        >
            <div
                onDragOver={(e) => e.preventDefault()}
                onDrop={handleDrop}
                className="group relative border-2 border-dashed border-white/20 rounded-3xl p-12 text-center hover:border-purple-500/50 transition-colors duration-300"
            >
                <div className="absolute inset-0 rounded-3xl bg-gradient-to-r from-purple-500/10 to-blue-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                <div className="relative space-y-4">
                    <div className="w-20 h-20 mx-auto rounded-full bg-white/5 flex items-center justify-center">
                        <Upload className="w-10 h-10 text-purple-500" />
                    </div>
                    <h3 className="text-2xl font-semibold">Drop your room image here</h3>
                    <p className="text-gray-400">or</p>
                    <label className="inline-block">
                        <input
                            type="file"
                            accept="image/*"
                            onChange={handleFileInput}
                            className="hidden"
                        />
                        <span className="px-6 py-3 bg-purple-500 rounded-full hover:bg-purple-600 transition-colors cursor-pointer inline-flex items-center gap-2">
                            <Sparkles className="w-4 h-4" />
                            Browse Files
                        </span>
                    </label>
                </div>
            </div>
        </motion.div>
    );
} 