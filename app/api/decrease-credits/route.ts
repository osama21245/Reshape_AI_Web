import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { User } from "@/config/schema";
import { eq, sql } from "drizzle-orm";

export async function POST(request: Request) {
    try {
        const { email } = await request.json();

        const user = await db
            .select()
            .from(User)
            .where(eq(User.email, email))
            .limit(1);

        if (!user.length || (user[0]?.credits ?? 0) < 1) {
            return NextResponse.json(
                { error: "Insufficient credits" },
                { status: 400 }
            );
        }

        const updatedUser = await db
            .update(User)
            .set({
                credits: sql`${User.credits} - 1`
            })
            .where(eq(User.email, email))
            .returning();

        return NextResponse.json({ success: true, credits: updatedUser[0].credits });
    } catch (error) {
        console.error("Error decreasing credits:", error);
        return NextResponse.json(
            { error: "Failed to decrease credits" },
            { status: 500 }
        );
    }
} 