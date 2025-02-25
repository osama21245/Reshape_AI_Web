"use client";
import { motion } from "framer-motion";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { ArrowRight, Sparkles, Zap, Star, Shield } from "lucide-react";
import { useUser } from "@clerk/nextjs";
import { useRouter } from "next/navigation";

export default function Home() {
  const { user, isLoaded } = useUser();
  const router = useRouter();
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  
  const images = [
    '/welcome_screen1.jpg',
    '/welcome_screen2.jpg',
    '/welcome_screen3.jpg',
    '/welcome_screen4.jpg',
  ];

  const features = [
    { icon: Sparkles, title: "AI-Powered Design", description: "Transform your space with cutting-edge AI technology" },
    { icon: Zap, title: "Instant Results", description: "Get redesigns in seconds, not days" },
    { icon: Star, title: "Multiple Styles", description: "Choose from various interior design styles" },
    { icon: Shield, title: "Secure & Private", description: "Your data is always protected" },
  ];

  useEffect(() => {
    if (isLoaded && user) {
      router.push('/dashboard');
    }
  }, [isLoaded, user, router]);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentImageIndex((prev) => (prev + 1) % images.length);
    }, 3000);
    return () => clearInterval(interval);
  }, [images.length]);

  if (!isLoaded || user) {
    return null;
  }

  return (
    <div className="relative min-h-screen">
      {/* Background Image */}
      <div className="fixed inset-0 -z-10">
        <Image
          src="/background-welcome.jpg"
          alt="Background"
          fill
          className="object-cover opacity-20"
          priority
        />
        <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-black/80 to-black/90" />
      </div>

      {/* Hero Section */}
      <div className="relative pt-32 pb-16 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-8"
            >
              <h1 className="text-5xl md:text-6xl font-bold bg-gradient-to-r from-purple-400 via-blue-400 to-purple-400 bg-clip-text text-transparent">
                Reshape Your Space with AI
              </h1>
              <p className="text-xl text-gray-300 leading-relaxed">
                Transform your living spaces instantly using advanced AI technology. 
                Upload a photo and watch your room transform into your dream design.
              </p>
              <div className="flex gap-4">
                <Link href="/sign-up">
                  <motion.button
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className="px-8 py-4 bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl font-medium flex items-center gap-2"
                  >
                    Get Started
                    <ArrowRight className="w-5 h-5" />
                  </motion.button>
                </Link>
                <Link href="/dashboard">
                  <motion.button
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className="px-8 py-4 bg-white/10 rounded-xl font-medium hover:bg-white/20 transition-colors"
                  >
                    View Demo
                  </motion.button>
                </Link>
              </div>
            </motion.div>

            {/* Image Carousel */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="relative h-[600px] rounded-2xl overflow-hidden"
            >
              {images.map((src, index) => (
                <motion.div
                  key={src}
                  initial={{ opacity: 0 }}
                  animate={{ opacity: index === currentImageIndex ? 1 : 0 }}
                  transition={{ duration: 0.5 }}
                  className="absolute inset-0"
                >
                  <Image
                    src={src}
                    alt={`Welcome screen ${index + 1}`}
                    fill
                    className="object-cover rounded-2xl"
                    priority
                  />
                </motion.div>
              ))}
            </motion.div>
          </div>
        </div>
      </div>

      {/* Features Section */}
      <div className="py-24 px-4 bg-black/50 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto">
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((Feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                viewport={{ once: true }}
                className="p-6 bg-white/5 backdrop-blur-sm rounded-2xl border border-white/10"
              >
                <div className="w-12 h-12 bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl flex items-center justify-center mb-4">
                  <Feature.icon className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-semibold mb-2">{Feature.title}</h3>
                <p className="text-gray-400">{Feature.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </div>

      {/* Preview Gallery */}
      <div className="py-24 px-4">
        <div className="max-w-7xl mx-auto space-y-16">
          <div className="text-center space-y-4">
            <h2 className="text-4xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
              Amazing Transformations
            </h2>
            <p className="text-gray-400">See what others have created with Reshape</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[1, 2, 3, 4].map((i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                whileHover={{ scale: 1.02 }}
                className="relative aspect-[4/3] rounded-2xl overflow-hidden group"
              >
                <Image
                  src={`/dashboard_preview${i}.jpg`}
                  alt={`Preview ${i}`}
                  fill
                  className="object-cover transition-transform duration-500 group-hover:scale-110"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}


