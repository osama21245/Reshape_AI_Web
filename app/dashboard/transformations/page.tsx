"use client";
import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { useUser } from "@clerk/nextjs";
import { BeforeAfterSlider } from "../upload/_components/BeforeAfterSlider";
import { Clock, Image as ImageIcon } from "lucide-react";

interface Transformation {
    id: number;
    originalImageUrl: string;
    aiGeneratedImageUrl: string;
    roomType: string;
    style: string;
    customization: string;
    createdAt: string;
}

export default function TransformationsPage() {
    const { user } = useUser();
    const [transformations, setTransformations] = useState<Transformation[]>([]);
    const [selectedTransformation, setSelectedTransformation] = useState<Transformation | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchTransformations = async () => {
            try {
                const response = await fetch(`/api/transformations?email=${user?.primaryEmailAddress?.emailAddress}`);
                const data = await response.json();
                setTransformations(data);
            } catch (error) {
                console.error("Error fetching transformations:", error);
            } finally {
                setLoading(false);
            }
        };

        if (user?.primaryEmailAddress?.emailAddress) {
            fetchTransformations();
        }
    }, [user?.primaryEmailAddress?.emailAddress]);

    return (
        <div className="min-h-screen py-20 px-4">
            <div className="max-w-6xl mx-auto space-y-8">
                <div className="text-center space-y-4">
                    <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                        My Transformations
                    </h1>
                    <p className="text-gray-400">View all your AI room transformations</p>
                </div>

                {loading ? (
                    <div className="flex justify-center items-center min-h-[400px]">
                        <div className="w-16 h-16 border-4 border-purple-500 border-t-transparent rounded-full animate-spin" />
                    </div>
                ) : transformations.length === 0 ? (
                    <div className="text-center py-20 bg-white/5 backdrop-blur-sm rounded-2xl border border-white/10">
                        <ImageIcon className="w-16 h-16 mx-auto text-gray-400 mb-4" />
                        <h3 className="text-xl font-semibold mb-2">No transformations yet</h3>
                        <p className="text-gray-400">Start by transforming your first room!</p>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {transformations.map((transformation) => (
                            <motion.div
                                key={transformation.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                className="group relative bg-white/5 backdrop-blur-sm rounded-2xl border border-white/10 overflow-hidden"
                            >
                                <div className="aspect-[4/3] relative">
                                    <img
                                        src={transformation.aiGeneratedImageUrl}
                                        alt={`${transformation.roomType} transformation`}
                                        className="w-full h-full object-cover"
                                    />
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
                                        <div className="absolute bottom-0 left-0 right-0 p-6">
                                            <div className="space-y-2">
                                                <h3 className="text-lg font-semibold capitalize">
                                                    {transformation.roomType} - {transformation.style}
                                                </h3>
                                                <div className="flex items-center gap-2 text-sm text-gray-400">
                                                    <Clock className="w-4 h-4" />
                                                    {new Date(transformation.createdAt).toLocaleDateString()}
                                                </div>
                                            </div>
                                            <motion.button
                                                onClick={() => setSelectedTransformation(transformation)}
                                                className="mt-4 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-lg text-sm hover:bg-white/20 transition-colors"
                                                whileHover={{ scale: 1.02 }}
                                                whileTap={{ scale: 0.98 }}
                                            >
                                                View Comparison
                                            </motion.button>
                                        </div>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                )}
            </div>

            {selectedTransformation && (
                <BeforeAfterSlider
                    beforeImage={selectedTransformation.originalImageUrl}
                    afterImage={selectedTransformation.aiGeneratedImageUrl}
                    onClose={() => setSelectedTransformation(null)}
                    imageId={selectedTransformation.id}
                />
            )}
        </div>
    );
} 