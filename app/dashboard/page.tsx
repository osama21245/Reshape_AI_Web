"use client";
//import { auth } from "@clerk/nextjs/server";
//import { UserButton } from "@clerk/nextjs";
import Image from "next/image";
import { motion } from "framer-motion";
import { useState, useEffect } from "react";
import { X, Upload, Sparkles, ArrowRight, Zap, Users, Clock } from "lucide-react";
import AnimatedBackground from "./_components/AnimatedBackground";
import { useSearchParams } from 'next/navigation';
import { toast } from 'react-hot-toast';
import Link from "next/link";
//import { redirect } from "next/navigation";

function DashboardPage() {
    const [selectedImage, setSelectedImage] = useState<number | null>(null);
    const searchParams = useSearchParams();
    const showSuccess = searchParams.get('success');

    // const {userId} = auth();
    // if(!userId){
    //     redirect("/sign-in");
    // }

    // Prevent scroll when modal is open
    useEffect(() => {
        if (selectedImage !== null) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = 'unset';
        }
    }, [selectedImage]);

    useEffect(() => {
        if (showSuccess) {
            // Show success toast or dialog
            toast.success('Credits added successfully!');
        }
    }, [showSuccess]);

    return (
        <>
            <AnimatedBackground />
            <div className="space-y-16 relative">
                {/* Hero Section */}
                <section className="relative min-h-[80vh] flex items-center justify-center overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-b from-blue-500/10 via-purple-500/10 to-pink-500/10 animate-gradient-xy rounded-3xl" />
                    <div className="absolute inset-0 overflow-hidden rounded-3xl">
                        <video 
                            autoPlay 
                            loop 
                            muted 
                            className="absolute w-full h-full object-cover opacity-30"
                        >
                            <source src="/dashboard_video.mp4" type="video/mp4" />
                        </video>
                    </div>
                    
                    <div className="relative z-10 p-8 max-w-4xl mx-auto">
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.7 }}
                            className="text-center space-y-8"
                        >
                            <div className="space-y-4">
                                <motion.div
                                    initial={{ scale: 0.95 }}
                                    animate={{ scale: 1 }}
                                    transition={{ 
                                        duration: 2,
                                        repeat: Infinity,
                                        repeatType: "reverse"
                                    }}
                                    className="inline-block"
                                >
                                    <h1 className="text-6xl md:text-7xl font-bold bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent pb-2">
                                        Reshape Your Space
                                    </h1>
                                </motion.div>
                                <p className="text-xl text-gray-300/90 max-w-2xl mx-auto leading-relaxed">
                                    Experience the future of interior design with our AI-powered transformation system
                                </p>
                            </div>
                            
                            <motion.div
                                initial={{ opacity: 0, scale: 0.9 }}
                                animate={{ opacity: 1, scale: 1 }}
                                transition={{ delay: 0.3, duration: 0.5 }}
                                className="flex justify-center"
                            >
                                <Link href="/dashboard/upload">
                                    <motion.button 
                                        className="group relative px-10 py-5 bg-gradient-to-r from-blue-600 to-purple-600 rounded-2xl hover:scale-105 transition-all duration-300"
                                        whileHover={{ scale: 1.05 }}
                                        whileTap={{ scale: 0.95 }}
                                    >
                                        <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-blue-600 to-purple-600 blur-xl opacity-50 group-hover:opacity-75 transition-opacity" />
                                        <div className="relative flex items-center gap-3 text-lg font-medium">
                                            <Upload className="w-6 h-6" />
                                            <span>Transform Your Room</span>
                                            <Sparkles className="w-6 h-6" />
                                        </div>
                                    </motion.button>
                                </Link>
                            </motion.div>
                        </motion.div>
                    </div>

                    {/* Floating Elements */}
                    <div className="absolute inset-0 pointer-events-none">
                        {[...Array(3)].map((_, i) => (
                            <motion.div
                                key={i}
                                initial={{ opacity: 0, scale: 0.5, x: -100 }}
                                animate={{ 
                                    opacity: [0.5, 0.8, 0.5],
                                    scale: [1, 1.2, 1],
                                    x: [0, 50, 0],
                                }}
                                transition={{
                                    duration: 8,
                                    delay: i * 2,
                                    repeat: Infinity,
                                    repeatType: "reverse"
                                }}
                                className="absolute w-32 h-32 bg-gradient-to-r from-purple-500/20 to-pink-500/20 rounded-full blur-3xl"
                                style={{
                                    top: `${20 + i * 30}%`,
                                    left: `${10 + i * 20}%`,
                                }}
                            />
                        ))}
                    </div>
                </section>

                {/* Stats Section with 3D Cards */}
                <section className="relative py-16">
                    <div className="max-w-7xl mx-auto px-4 grid grid-cols-1 md:grid-cols-3 gap-8">
                        {[
                            { label: "AI Transformations", value: "10,234+", icon: Zap, color: "from-blue-500 to-cyan-500" },
                            { label: "Active Creators", value: "5,678", icon: Users, color: "from-purple-500 to-pink-500" },
                            { label: "Average Time", value: "~2 mins", icon: Clock, color: "from-orange-500 to-red-500" },
                        ].map((stat, i) => (
                            <motion.div 
                                key={i}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                transition={{ delay: i * 0.2 }}
                                viewport={{ once: true }}
                                whileHover={{ scale: 1.05, rotateY: 10 }}
                                className="group relative p-8 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 overflow-hidden"
                            >
                                <div className="absolute inset-0 bg-gradient-to-r opacity-0 group-hover:opacity-10 transition-opacity duration-500"
                                    style={{
                                        backgroundImage: `linear-gradient(to right, ${stat.color})`
                                    }}
                                />
                                <stat.icon className="w-8 h-8 mb-4 text-gray-400 group-hover:text-white transition-colors" />
                                <h3 className="text-4xl font-bold bg-gradient-to-r bg-clip-text text-transparent mb-2"
                                    style={{
                                        backgroundImage: `linear-gradient(to right, ${stat.color})`,
                                        WebkitTextStroke: '1px white'
                                    }}
                                >
                                    {stat.value}
                                </h3>
                                <p className="text-gray-400 group-hover:text-white transition-colors">
                                    {stat.label}
                                </p>
                            </motion.div>
                        ))}
                    </div>
                </section>

                {/* Gallery Section */}
                <section className="relative py-16">
                    <h2 className="text-4xl font-bold text-center bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent mb-16">
                        Featured Transformations
                    </h2>
                    <div className="max-w-7xl mx-auto px-4 grid grid-cols-1 md:grid-cols-2 gap-8">
                        {[8, 1, 3, 6].map((i) => (
                            <motion.div
                                key={i}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ delay: i * 0.1 }}
                                className="group relative aspect-[4/3] overflow-hidden rounded-2xl"
                                whileHover={{ scale: 1.02 }}
                            >
                                <Image
                                    src={`/dashboard_preview${i}.jpg`}
                                    alt={`Preview ${i}`}
                                    fill
                                    className="object-cover transition-transform duration-500 group-hover:scale-110"
                                />
                                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-all duration-300">
                                    <div className="absolute inset-0 flex flex-col justify-end p-8">
                                        <motion.h3 
                                            initial={{ opacity: 0, y: 20 }}
                                            whileInView={{ opacity: 1, y: 0 }}
                                            className="text-xl font-semibold mb-2"
                                        >
                                            Modern Room
                                        </motion.h3>
                                        <motion.p 
                                            initial={{ opacity: 0 }}
                                            whileInView={{ opacity: 0.7 }}
                                            className="text-sm mb-4"
                                        >
                                            Explore the evolution of design
                                        </motion.p>
                                        <motion.button 
                                            onClick={() => setSelectedImage(i)}
                                            className="flex items-center gap-2 w-fit px-4 py-2 bg-white/10 backdrop-blur-md rounded-full text-sm hover:bg-white/20 transition-colors"
                                            whileHover={{ scale: 1.05 }}
                                            whileTap={{ scale: 0.95 }}
                                        >
                                            <span>View Transformation</span>
                                            <ArrowRight className="w-4 h-4" />
                                        </motion.button>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </section>
            </div>

            {/* Enhanced Modal */}
            {selectedImage && (
                <motion.div 
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    className="fixed inset-0 bg-black/95 backdrop-blur-xl z-50 flex items-center justify-center"
                    onClick={() => setSelectedImage(null)}
                >
                    <motion.div 
                        initial={{ scale: 0.9, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className="relative w-[95vw] h-[95vh] flex items-center justify-center"
                        onClick={e => e.stopPropagation()}
                    >
                        <motion.button 
                            onClick={() => setSelectedImage(null)}
                            className="absolute top-4 right-4 text-white/80 hover:text-white z-50 bg-black/20 backdrop-blur-md rounded-full p-3"
                            whileHover={{ scale: 1.1 }}
                            whileTap={{ scale: 0.9 }}
                        >
                            <X className="w-6 h-6" />
                        </motion.button>
                        <Image
                            src={`/dashboard_preview${selectedImage}.jpg`}
                            alt={`Preview ${selectedImage}`}
                            fill
                            className="object-contain"
                            quality={100}
                            priority
                        />
                    </motion.div>
                </motion.div>
            )}
        </>
    );
}

export default DashboardPage;
