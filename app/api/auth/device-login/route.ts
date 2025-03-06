import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { User, AuthToken, DeviceLogin } from "@/config/schema";
import { eq, and } from "drizzle-orm";

export async function POST(request: Request) {
  try {
    const { token, deviceName, deviceLocation } = await request.json();

    if (!token || !deviceName) {
      return NextResponse.json(
        { error: "Token and device name are required" },
        { status: 400 }
      );
    }

    // Find the token in the database
    const authTokens = await db
      .select()
      .from(AuthToken)
      .where(
        and(
          eq(AuthToken.token, token),
          eq(AuthToken.isUsed, false)
        )
      )
      .limit(1);

    if (!authTokens.length) {
      return NextResponse.json({ error: "Invalid or expired token" }, { status: 401 });
    }

    const authToken = authTokens[0];

    // Check if token is expired
    if (new Date(authToken.expiresAt) < new Date()) {
      return NextResponse.json({ error: "Token expired" }, { status: 401 });
    }

    // Mark token as used
    await db
      .update(AuthToken)
      .set({ isUsed: true })
      .where(eq(AuthToken.id, authToken.id));

    // Create device login record
    const [deviceLogin] = await db
      .insert(DeviceLogin)
      .values({
        userId: authToken.userId,
        deviceName: deviceName,
        deviceLocation: deviceLocation || null,
        tokenId: authToken.id,
        lastLoginAt: new Date(),
        isActive: true,
      })
      .returning();

    // Get user information
    const users = await db
      .select()
      .from(User)
      .where(eq(User.id, authToken.userId))
      .limit(1);

    if (!users.length) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    const user = users[0];

    // Return success with user data (excluding sensitive information)
    return NextResponse.json({
      success: true,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        credits: user.credits,
      },
      deviceLogin: {
        id: deviceLogin.id,
        deviceName: deviceLogin.deviceName,
        lastLoginAt: deviceLogin.lastLoginAt,
      }
    });
  } catch (error) {
    console.error("Error processing device login:", error);
    return NextResponse.json(
      { error: "Failed to process device login" },
      { status: 500 }
    );
  }
} 