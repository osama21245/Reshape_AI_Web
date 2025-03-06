import { NextResponse } from "next/server";
import { withApiAuth } from "../../auth/middleware";
import { db } from "@/config/db";
import { AiGeneratedImages, User } from "@/config/schema";
import { eq } from "drizzle-orm";

// Endpoint for mobile app to get user data after QR authentication
export async function GET(request: Request) {
  return withApiAuth(request, async (userid, req) => {
    try {
      // Get user's profile data
      const user = await db
        .select()
        .from(User)
        .where(eq(User.id, userid))
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
        .limit(10);

      // Return user profile with recent transformations
      return NextResponse.json({
        user: {
          id: user[0].id,
          name: user[0].name,
          email: user[0].email,
          image: user[0].image
        },
        transformations: transformations.map(t => ({
          id: t.id,
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
  });
}

// Simple endpoint to get user data by ID
export async function POST(request: Request) {
  try {
    const { userId } = await request.json();
    
    if (!userId) {
      return NextResponse.json({ error: "User ID is required" }, { status: 400 });
    }

    console.log("Getting user data for ID:", userId);

    // Get user data
    const user = await db
      .select()
      .from(User)
      .where(eq(User.id, userId))
      .limit(1);

    if (!user || user.length === 0) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Return user data
    return NextResponse.json({
      user: {
        id: user[0].id,
        name: user[0].name,
        email: user[0].email,
        image: user[0].image
      }
    });
  } catch (error) {
    console.error("Error:", error);
    return NextResponse.json({ error: "Failed to get user data" }, { status: 500 });
  }
} 