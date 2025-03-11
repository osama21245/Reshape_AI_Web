import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { AiGeneratedImages, User, AuthToken } from "@/config/schema";
import { eq, and, desc } from "drizzle-orm";

// Endpoint for mobile app to get user data after QR authentication
export async function GET(request: Request) {
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

    // Get user ID from query parameters
    const url = new URL(request.url);
    const userId = url.searchParams.get("userId");
    
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

    // Get user's profile data
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

    // Get user's recent transformations
    const transformations = await db
      .select()
      .from(AiGeneratedImages)
      .where(eq(AiGeneratedImages.userEmail, user[0].email))
      ;

    // Return user profile with recent transformations
    return NextResponse.json({
      user: {
        id: user[0].id,
        name: user[0].name,
        email: user[0].email,
        image: user[0].image,
        credits: user[0].credits
      },
      transformations: transformations.map(t => ({
        id: t.id,
        userId: user[0].id.toString(),
        originalImageUrl: t.originalImageUrl,
        transformedImageUrl: t.aiGeneratedImageUrl,
        style: t.style,
        createdAt: t.createdAt
      }))
    });
  } catch (error) {
    console.error("Error fetching user profile:", error);
    return NextResponse.json(
      { error: "Failed to fetch user profile" },
      { status: 500 }
    );
  }
}

// Simple endpoint to get user data by ID
export async function POST(request: Request) {
  try {
    const { userId, token } = await request.json();
    
    if (!userId) {
      return NextResponse.json({ error: "User ID is required" }, { status: 400 });
    }

    if (!token) {
      return NextResponse.json({ error: "Token is required" }, { status: 400 });
    }

    console.log("Getting user data for ID:", userId);

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
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Get user's recent transformations
    const transformations = await db
      .select()
      .from(AiGeneratedImages)
      .where(eq(AiGeneratedImages.userEmail, user[0].email))
      .orderBy(desc(AiGeneratedImages.createdAt))
      .limit(10);

    // Return user data
    return NextResponse.json({
      user: {
        id: user[0].id,
        name: user[0].name,
        email: user[0].email,
        image: user[0].image,
        credits: user[0].credits,
      },
      transformations: transformations.map(t => ({
        id: t.id,
        userId: user[0].id.toString(),
        originalImageUrl: t.originalImageUrl,
        transformedImageUrl: t.aiGeneratedImageUrl,
        style: t.style,
        createdAt: t.createdAt
      }))
    });
  } catch (error) {
    console.error("Error:", error);
    return NextResponse.json({ error: "Failed to get user data" }, { status: 500 });
  }
} 