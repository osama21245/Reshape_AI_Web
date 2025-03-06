import { NextResponse } from "next/server";
import { db } from "@/config/db";
import { AuthToken, User } from "@/config/schema";
import { eq, and, gt } from "drizzle-orm";

export async function validateApiToken(request: Request) {
  // Get the authorization header
  const authHeader = request.headers.get("Authorization");
  
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return {
      isValid: false,
      error: "Missing or invalid authorization header",
      status: 401
    };
  }

  // Extract the token
  const token = authHeader.substring(7);
  
  if (!token) {
    return {
      isValid: false,
      error: "No token provided",
      status: 401
    };
  }

  try {
    // Find the token in the database
    const authTokens = await db
      .select()
      .from(AuthToken)
      .where(
        and(
          eq(AuthToken.token, token),
          eq(AuthToken.isUsed, true), // Token should be used (meaning device login was successful)
          gt(AuthToken.expiresAt, new Date()) // Token should not be expired
        )
      )
      .limit(1);

    if (!authTokens.length) {
      return {
        isValid: false,
        error: "Invalid or expired token",
        status: 401
      };
    }

    const authToken = authTokens[0];

    // Get user information
    const users = await db
      .select()
      .from(User)
      .where(eq(User.id, authToken.userId))
      .limit(1);

    if (!users.length) {
      return {
        isValid: false,
        error: "User not found",
        status: 404
      };
    }

    // Return success with user data
    return {
      isValid: true,
      user: users[0],
      token: authToken
    };
  } catch (error) {
    console.error("Error validating API token:", error);
    return {
      isValid: false,
      error: "Error validating token",
      status: 500
    };
  }
}

// Middleware for API authentication
export async function withApiAuth(
  request: Request,
  handler: (userId: number, request: Request) => Promise<NextResponse>
) {
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

    // Find the token in the database
    const authToken = await db
      .select()
      .from(AuthToken)
      .where(eq(AuthToken.token, token))
      .limit(1);

    if (!authToken || authToken.length === 0) {
      return NextResponse.json(
        { error: "Unauthorized - Invalid token" },
        { status: 401 }
      );
    }

    // Call the handler with the user ID
    return await handler(authToken[0].userId, request);
  } catch (error) {
    console.error("Authentication error:", error);
    return NextResponse.json(
      { error: "Authentication failed" },
      { status: 500 }
    );
  }
} 