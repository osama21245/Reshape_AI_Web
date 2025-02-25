import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { AiGeneratedImages } from "@/config/schema";
import { eq } from "drizzle-orm";

export async function GET(request: Request) {
    try {
        const { searchParams } = new URL(request.url);
        const email = searchParams.get('email');

        if (!email) {
            return NextResponse.json({ error: "Email is required" }, { status: 400 });
        }

        const transformations = await db
            .select()
            .from(AiGeneratedImages)
            .where(eq(AiGeneratedImages.userEmail, email))
            .orderBy(AiGeneratedImages.createdAt);

        return NextResponse.json(transformations);
    } catch (error) {
        console.error("Error fetching transformations:", error);
        return NextResponse.json(
            { error: "Failed to fetch transformations" },
            { status: 500 }
        );
    }
} 