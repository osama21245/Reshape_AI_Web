import { db } from "@/config/db";
import { User, AuthToken } from "@/config/schema";
import { NextResponse } from "next/server";
import { eq, and } from "drizzle-orm";

export async function POST(request: Request) {
  try {
    // Get the authorization header
    const authHeader = request.headers.get("authorization");
    
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return NextResponse.json(
        { error: "Unauthorized - Missing or invalid token" },
        { status: 401 }
      );
    }

    // Extract the token
    const token = authHeader.split(" ")[1];
    
    if (!token) {
      return NextResponse.json(
        { error: "Unauthorized - Missing token" },
        { status: 401 }
      );
    }

    const { userId } = await request.json();

    if (!userId) {
      return NextResponse.json(
        { error: "User ID is required" },
        { status: 400 }
      );
    }

    // Validate the token in the database
    const authToken = await db
      .select()
      .from(AuthToken)
      .where(
        and(
          eq(AuthToken.token, token),
          eq(AuthToken.userId, parseInt(userId))
        )
      )
      .limit(1);

    if (!authToken || authToken.length === 0) {
      return NextResponse.json(
        { error: "Invalid token or token does not belong to this user" },
        { status: 401 }
      );
    }

    // Check if token is expired
    if (new Date(authToken[0].expiresAt) < new Date()) {
      return NextResponse.json(
        { error: "Token has expired" },
        { status: 603 }
      );
    }

    // Get user data
    const user = await db
      .select()
      .from(User)
      .where(eq(User.id, parseInt(userId)))
      .limit(1);

    if (!user || user.length === 0) {
      return NextResponse.json(
        { error: "User not found" },
        { status: 404 }
      );
    }

    const currentCredits = user[0]?.credits ?? 0;
    
    // Check if user has enough credits
    if (currentCredits < 1) {
      return NextResponse.json(
        { 
          error: "Insufficient credits",
          credits: currentCredits,
          success: false
        },
        { status: 200 }
      );
    }

    // Update user credits in the database (deduct 1 credit)
    await db
      .update(User)
      .set({ 
        credits: currentCredits - 1 
      })
      .where(eq(User.id, parseInt(userId)));

    // Get updated user data
    const updatedUser = await db
      .select()
      .from(User)
      .where(eq(User.id, parseInt(userId)))
      .limit(1);

    // Return success with updated credits information
    return NextResponse.json({
      credits: updatedUser[0]?.credits ?? 0,
      success: true
    });
  } catch (error) {
    console.error("Error updating credits:", error);
    return NextResponse.json(
      { error: "Failed to update credits" },
      { status: 500 }
    );
  }
} 