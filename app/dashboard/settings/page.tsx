"use client";
import { motion } from "framer-motion";
import { useUser } from "@clerk/nextjs";
import { Zap } from "lucide-react";
import Link from "next/link";
import QRCodeLogin from "./_components/QRCodeLogin";
import { useUserDetails } from "@/app/context/UserDetailsContext";

export default function SettingsPage() {
    const { user } = useUser();
    const { userDetails } = useUserDetails();
   
    return (
        <div className="min-h-screen py-20 px-4">
            <div className="max-w-4xl mx-auto space-y-12">
                <div className="text-center space-y-4">
                    <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
                        Account Settings
                    </h1>
                    <p className="text-gray-400">Manage your account information</p>
                </div>

                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white/5 backdrop-blur-sm rounded-2xl border border-white/10 p-8 space-y-8"
                >
                    <div className="flex items-center gap-6">
                     
                        <div>
                            <h2 className="text-2xl font-semibold">{user?.fullName}</h2>
                            <p className="text-gray-400">{user?.primaryEmailAddress?.emailAddress}</p>
                        </div>
                    </div>

                    <div className="grid gap-6">
                        <div className="space-y-2">
                            <label className="text-sm text-gray-400">Full Name</label>
                            <input
                                type="text"
                                value={user?.fullName || ""}
                                disabled
                                className="w-full bg-white/5 rounded-xl border border-white/10 px-4 py-3"
                            />
                        </div>

                        <div className="space-y-2">
                            <label className="text-sm text-gray-400">Email</label>
                            <input
                                type="email"
                                value={user?.primaryEmailAddress?.emailAddress || ""}
                                disabled
                                className="w-full bg-white/5 rounded-xl border border-white/10 px-4 py-3"
                            />
                        </div>
                    </div>

                    <div className="border-t border-white/10 pt-8">
                        <h3 className="text-xl font-semibold mb-4">Billing & Credits</h3>
                        <div className="flex items-center justify-between p-4 bg-white/5 rounded-xl">
                            <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-purple-500/20 rounded-full flex items-center justify-center">
                                    <Zap className="w-5 h-5 text-purple-400" />
                                </div>
                                <div>
                                    <p className="font-medium">Available Credits</p>
                                    <p className="text-sm text-gray-400">{userDetails.credits} credits remaining</p>
                                </div>
                            </div>
                            <Link href="/dashboard/billing">
                                <motion.button
                                    className="px-4 py-2 bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl font-medium hover:opacity-90 transition-opacity"
                                    whileHover={{ scale: 1.02 }}
                                    whileTap={{ scale: 0.98 }}
                                >
                                    Purchase Credits
                                </motion.button>
                            </Link>
                        </div>
                    </div>

                    {/* Mobile App Login Section */}
                    <div className="border-t border-white/10 pt-8">
                        <QRCodeLogin />
                    </div>

                    <div className="pt-4 border-t border-white/10">
                        <p className="text-sm text-gray-400">
                            To update your profile information, please use the Clerk user settings.
                        </p>
                    </div>
                </motion.div>
            </div>
        </div>
    );
}
