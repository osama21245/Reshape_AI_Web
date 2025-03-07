import type { Metadata } from "next";

import "./globals.css";

import { Outfit } from "next/font/google";
import { ClerkProvider } from "@clerk/nextjs";
import Providers from "@/components/provider";


export const metadata: Metadata = {
  title: "Reshape AI",
  description: "Reshape your space with AI",
};
const outfit = Outfit({
  subsets: ["latin"],
  variable: "--font-outfit",
});

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <meta
          name="format-detection"
          content="telephone=no, date=no, email=no, address=no"
        />
      </head>
      <body className={`${outfit.variable}`}>
        <ClerkProvider>
          <Providers>
            {children}
          </Providers>
        </ClerkProvider>
      </body>
    </html>
  );
}
