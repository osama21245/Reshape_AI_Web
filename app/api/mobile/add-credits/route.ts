import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { User, AuthToken } from "@/config/schema";
import { eq, and, sql } from "drizzle-orm";

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

    // Get request body
    const { userId, credits, paymentId } = await request.json();
    
    if (!userId || !credits) {
      return NextResponse.json(
        { error: "Missing required fields: userId and credits are required" },
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

    // Add credits to user
    const updatedUser = await db
      .update(User)
      .set({
        credits: sql`${User.credits} + ${credits}`
      })
      .where(eq(User.id, parseInt(userId)))
      .returning({
        id: User.id,
        name: User.name,
        email: User.email,
        credits: User.credits
      });

    // Log the transaction
    console.log(`Credits added: ${credits} to user ${userId}. Payment ID: ${paymentId}`);

    return NextResponse.json({
      success: true,
      message: "Credits added successfully",
      user: updatedUser[0]
    });
  } catch (error) {
    console.error("Error adding credits:", error);
    return NextResponse.json(
      { error: "Failed to add credits", details: error },
      { status: 500 }
    );
  }
} 