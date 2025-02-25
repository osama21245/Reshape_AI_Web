"use client";
import Image from "next/image";
import { UserButton } from "@clerk/nextjs";
import Link from "next/link";
import { Star } from "lucide-react";
import { useEffect, useState } from "react";
import { useUserDetails } from "@/app/context/UserDetailsContext";
const Header = () => {
  const { userDetails } = useUserDetails();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return <div className="h-16" />; // Placeholder with same height
  }

  const menuItems = [
    { label: "Home", href: "/dashboard" },
    { label: "Upload", href: "/dashboard/upload" },
    { label: "My Transformations", href: "/dashboard/transformations" },
    { label: "Settings", href: "/dashboard/settings" },
  ];

  return (
    <header className="fixed w-full top-0 z-50 backdrop-blur-md bg-black/30 border-b border-white/10">
      <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
        <div className="flex items-center gap-8">
          <Link href="/dashboard" className="flex items-center gap-2">
            <Image
              src="/app_logo.jpg"
              alt="Reshape AI"
              width={40}
              height={40}
              className="rounded-full"
            />
            <span className="text-xl font-semibold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
              Reshape AI
            </span>
          </Link>
          
          <nav className="hidden md:flex items-center gap-6">
            {menuItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="text-gray-300 hover:text-white transition-colors duration-200"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </div>

        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2 bg-white/5 px-3 py-1.5 rounded-full">
            <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
            <span className="text-sm font-medium">{userDetails?.credits || 0} credits</span>
          </div>
          <div className="bg-gradient-to-r from-blue-500 to-purple-500 p-[1px] rounded-full">
            <UserButton
              afterSignOutUrl="/"
              appearance={{
                elements: {
                  avatarBox: "h-8 w-8"
                }
              }}
            />
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;

