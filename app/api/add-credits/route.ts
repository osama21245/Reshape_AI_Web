import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { User } from "@/config/schema";
import { eq, sql } from "drizzle-orm";

export async function POST(request: Request) {
    try {
        const { credits, email } = await request.json();

        const updatedUser = await db
            .update(User)
            .set({
                credits: sql`${User.credits} + ${credits}`
            })
            .where(eq(User.email, email))
            .returning();

        return NextResponse.json({ success: true, credits: updatedUser[0].credits });
    } catch (error) {
        console.error("Error adding credits:", error);
        return NextResponse.json(
            { error: "Failed to add credits" },
            { status: 500 }
        );
    }
} 