import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { AuthToken, DeviceLogin } from "@/config/schema";
import { eq, and } from "drizzle-orm";
import crypto from "crypto";

// Function to generate a secure random token
function generateSecureToken(length = 32) {
  return crypto.randomBytes(length).toString('hex');
}

export async function POST(request: Request) {
    try {
      // Get the device ID from the request
      const { deviceId, userId } = await request.json();

      
      if (!deviceId) {
        return NextResponse.json(
          { error: "Device ID is required" },
          { status: 400 }
        );
      }
      
      // Verify the device exists and belongs to this user
      const deviceLogins = await db
        .select()
        .from(DeviceLogin)
        .where(
          and(
            eq(DeviceLogin.id, parseInt(deviceId)),
            eq(DeviceLogin.userId, userId),
            eq(DeviceLogin.isActive, true)
          )
        )
        .limit(1);
        
      if (!deviceLogins.length) {
        return NextResponse.json(
          { error: "Device not found or not authorized" },
          { status: 404 }
        );
      }
      
      // Generate a new token
      const token = generateSecureToken();
      
      // Set expiration time (30 days from now for long-term access)
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 2);
      
      // Store the new token
      const [authToken] = await db
        .insert(AuthToken)
        .values({
          userId: userId,
          token: token,
          expiresAt: expiresAt,
          isUsed: true, // Mark as used immediately since this is a refresh
        })
        .returning();
        
      // Update the device login with the new token
      await db
        .update(DeviceLogin)
        .set({
          tokenId: authToken.id,
          lastLoginAt: new Date()
        })
        .where(eq(DeviceLogin.id, deviceLogins[0].id));
        
      // Return the new token
      return NextResponse.json({
        token: token,
        expiresAt: expiresAt.toISOString()
      });
    } catch (error) {
      console.error("Error refreshing token:", error);
      return NextResponse.json(
        { error: "Failed to refresh token" },
        { status: 500 }
      );
    
  };
} 