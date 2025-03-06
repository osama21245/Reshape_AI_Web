import { NextResponse } from "next/server";
import { db } from "@/config/db";
import {  AuthToken } from "@/config/schema";
import { eq } from "drizzle-orm";

// Simple endpoint for mobile app to authenticate with QR token
export async function POST(request: Request) {
  try {
    const { token } = await request.json();
    
    if (!token) {
      return NextResponse.json({ error: "Token is required" }, { status: 400 });
    }

    console.log("Authenticating with token:", token);

    // Find the auth token in the database
    const authToken = await db
      .select()
      .from(AuthToken)
      .where(eq(AuthToken.token, token))
      .limit(1);

    if (!authToken || authToken.length === 0) {
      return NextResponse.json({ error: "Invalid token" }, { status: 401 });
    }

    // Return the user ID and token
    return NextResponse.json({
      userId: authToken[0].userId,
      token: token
    });
  } catch (error) {
    console.error("Error:", error);
    return NextResponse.json({ error: "Authentication failed" }, { status: 500 });
  }
} 