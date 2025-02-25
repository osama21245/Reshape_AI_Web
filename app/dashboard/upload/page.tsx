"use client";
import { useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import AnimatedBackground from "../_components/AnimatedBackground";
import { UploadStep } from "./_components/UploadStep";
import { RoomTypeStep } from "./_components/RoomTypeStep";
import { StyleStep } from "./_components/StyleStep";
import { CustomizationStep } from "./_components/CustomizationStep";
import { SummaryStep } from "./_components/SummaryStep";
import { StepProgress } from "./_components/StepProgress";
import { storage } from "@/config/firebase";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import axios from "axios";
import { useUser } from "@clerk/nextjs";
import { BeforeAfterSlider } from "./_components/BeforeAfterSlider";
import { useUserDetails } from "@/app/context/UserDetailsContext";
import { toast } from "react-hot-toast";
import Link from "next/link";

export default function UploadPage() {
    const [selectedImage, setSelectedImage] = useState<File | null>(null);
    const [previewUrl, setPreviewUrl] = useState<string | null>(null);
    const [selectedRoomType, setSelectedRoomType] = useState<string | null>(null);
    const [selectedStyle, setSelectedStyle] = useState<string | null>(null);
    const [customization, setCustomization] = useState('');
    const [step, setStep] = useState(1);
    const {user} = useUser();
    const [isLoading, setIsLoading] = useState(false);
    const [generatedImageUrl, setGeneratedImageUrl] = useState<string | null>(null);
    const [showComparison, setShowComparison] = useState(false);
    const { userDetails, setUserDetails } = useUserDetails();

    const handleImageUpload = (file: File) => {
        setSelectedImage(file);
        setPreviewUrl(URL.createObjectURL(file));
        setStep(2);
    };

    const handleRoomTypeSelect = (roomType: string) => {
        setSelectedRoomType(roomType);
        setStep(3);
    };

    const handleStyleSelect = (style: string) => {
        setSelectedStyle(style);
        setStep(4);
    };

    const handleCustomization = () => {
        setStep(5); // Move to summary step
    };

    const handleBack = () => {
        setStep(step - 1);
    };

    const handleSubmit = async () => {
        // Check credits before proceeding
        if (userDetails.credits <= 0) {
            toast.error(
                <div className="flex flex-col gap-2">
                    <p>Insufficient credits!</p>
                    <Link 
                        href="/dashboard/billing" 
                        className="text-sm text-purple-400 hover:text-purple-300"
                    >
                        Purchase more credits →
                    </Link>
                </div>,
                {
                    duration: 5000,
                    style: {
                        background: 'rgba(255, 255, 255, 0.1)',
                        backdropFilter: 'blur(8px)',
                        border: '1px solid rgba(255, 255, 255, 0.1)',
                    }
                }
            );
            return;
        }

        try {
            setIsLoading(true);
            const url = await saveRowImageToFirebaseStorage();
            const response = await axios.post('/api/generate-photo', {
                imageUrl: url,
                roomType: selectedRoomType,
                style: selectedStyle,
                customization: customization,
                userEmail: user?.primaryEmailAddress?.emailAddress
            });

            // Update user credits in context
            setUserDetails({
                ...userDetails,
                credits: userDetails.credits - 1
            });

            // Set the generated image URL and show comparison
            setGeneratedImageUrl(response.data.url);
            setShowComparison(true);
            
        } catch (error) {
            console.error("Error generating photo:", error);
        } finally {
            setIsLoading(false);
        }
    };


    

    const saveRowImageToFirebaseStorage = async () => {
        const fileName = new Date().getTime() +"_raw.png"
        const storageRef = ref(storage, 'room_Redesign/'+fileName);
        await uploadBytes(storageRef, selectedImage!).then(() => {
            console.log('Uploaded a blob or file!');
        }).catch((error) => {
            console.error('Error uploading:', error);
        });
        const url = await getDownloadURL(storageRef);
        console.log(url);
        return url;
    };

    return (
        <>
            <AnimatedBackground />
            <div className="min-h-screen py-20 px-4">
                <div className="max-w-6xl mx-auto space-y-8">
                    <StepProgress currentStep={step} totalSteps={5} />
                    
                    <AnimatePresence mode="wait">
                        {step === 1 && <UploadStep onImageUpload={handleImageUpload} />}
                        {step === 2 && (
                            <RoomTypeStep 
                                onSelect={handleRoomTypeSelect}
                                onBack={handleBack}
                            />
                        )}
                        {step === 3 && (
                            <StyleStep 
                                onSelect={handleStyleSelect}
                                onBack={handleBack}
                            />
                        )}
                        {step === 4 && (
                            <CustomizationStep
                                value={customization}
                                onChange={setCustomization}
                                onSubmit={handleCustomization}
                                onBack={handleBack}
                            />
                        )}
                        {step === 5 && previewUrl && selectedRoomType && selectedStyle && (
                            <SummaryStep
                                imageUrl={previewUrl}
                                roomType={selectedRoomType}
                                style={selectedStyle}
                                customization={customization}
                                onBack={handleBack}
                                onSubmit={handleSubmit}
                            />
                        )}
                    </AnimatePresence>
                </div>

                {isLoading && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center"
                    >
                        <div className="text-center space-y-4">
                            <div className="w-16 h-16 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto" />
                            <p className="text-xl">Generating your AI room design...</p>
                        </div>
                    </motion.div>
                )}

                {showComparison && previewUrl && generatedImageUrl && (
                    <BeforeAfterSlider
                        beforeImage={previewUrl}
                        afterImage={generatedImageUrl}
                        onClose={() => setShowComparison(false)}
                       
                    />
                )}
            </div>
        </>
    );
} 