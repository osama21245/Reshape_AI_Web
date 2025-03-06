import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { User, AuthToken } from "@/config/schema";
import { eq } from "drizzle-orm";
import { auth, currentUser } from "@clerk/nextjs/server";
import crypto from "crypto";

// Function to generate a secure random token
function generateSecureToken(length = 32) {
  return crypto.randomBytes(length).toString('hex');
}

export async function POST() {
  try {
    // Get the authenticated user from Clerk
    const { userId } = await auth();
    
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Get the current user from Clerk
    const clerkUser = await currentUser();
    if (!clerkUser || !clerkUser.emailAddresses || clerkUser.emailAddresses.length === 0) {
      return NextResponse.json({ error: "User email not found" }, { status: 400 });
    }

    const email = clerkUser.emailAddresses[0].emailAddress;

    try {
      // Find the user in our database
      const userInfo = await db
        .select()
        .from(User)
        .where(eq(User.email, email))
        .limit(1);

      if (!userInfo.length) {
        return NextResponse.json({ error: "User not found in database" }, { status: 404 });
      }

      const dbUser = userInfo[0];

      // Generate a secure token
      const token = generateSecureToken();
      
      // Set expiration time (15 minutes from now)
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 15);

      try {
        // Store the token in the database
         await db
          .insert(AuthToken)
          .values({
            userId: dbUser.id,
            token: token,
            expiresAt: expiresAt,
            isUsed: false,
          })
          .returning();

        // Return the token and expiration time
        return NextResponse.json({
          token: token,
          expiresAt: expiresAt.toISOString(),
          userId: dbUser.id
        });
      } catch (dbError) {
        console.error("Database error storing token:", dbError);
        return NextResponse.json(
          { error: "Failed to store authentication token" },
          { status: 500 }
        );
      }
    } catch (dbError) {
      console.error("Database error finding user:", dbError);
      return NextResponse.json(
        { error: "Database error while looking up user" },
        { status: 500 }
      );
    }
  } catch (error) {
    console.error("Error generating QR token:", error);
    return NextResponse.json(
      { error: "Failed to generate QR token" },
      { status: 500 }
    );
  }
} 