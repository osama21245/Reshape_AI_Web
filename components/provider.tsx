"use client";
import React, { useEffect, useState } from "react";
import { useUser } from "@clerk/nextjs";
import axios from "axios";
import { UserDetailsContext, UserDetails } from "@/app/context/UserDetailsContext";
import {  PayPalScriptProvider } from "@paypal/react-paypal-js";

function Providers({ children }: { children: React.ReactNode }) {
    const { user, isLoaded } = useUser();
    const [mounted, setMounted] = useState(false);
    const [userDetails, setUserDetails] = useState<UserDetails>({
        credits: 0,
        name: "",
        email: "",
        image: "",
        id: 0,
    });

    useEffect(() => {
        setMounted(true);
    }, []);

    useEffect(() => {
        if (isLoaded && user && mounted) {
            VerifyUser();
        }
    }, [user, isLoaded, mounted]);

    const VerifyUser = async () => {
        try {
            const dataResponse = await axios.post("/api/verify-user", { user: user });
            setUserDetails(dataResponse.data.result);
        } catch (error) {
            console.error("Error verifying user:", error);
        }
    }

    if (!mounted) return null;

    return (
        <UserDetailsContext.Provider value={{ 
            userDetails, 
            setUserDetails: (details: UserDetails) => setUserDetails(details) 
        }}>
            <PayPalScriptProvider options={{ clientId: process.env.NEXT_PUBLIC_PAYPAL_CLIENT_ID!}}>
                {children}
            </PayPalScriptProvider>
        </UserDetailsContext.Provider>
    );
}

export default Providers;