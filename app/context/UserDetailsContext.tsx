"use client";
import { createContext, useContext } from 'react';

export interface UserDetails {
    id?: number;
    credits: number;
    name: string;
    email: string;
    image: string;
}

interface UserDetailsContextType {
    userDetails: UserDetails;
    setUserDetails: (details: UserDetails) => void;
}

export const UserDetailsContext = createContext<UserDetailsContextType | undefined>(undefined);

export function useUserDetails() {
    const context = useContext(UserDetailsContext);
    if (!context) {
        throw new Error('useUserDetails must be used within a UserDetailsProvider');
    }
    return context;
} 