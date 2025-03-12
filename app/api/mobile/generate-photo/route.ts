import { db } from "@/config/db";
import { storage } from "@/config/firebase";
import { AiGeneratedImages, User, AuthToken } from "@/config/schema";
import axios from "axios";
import { getDownloadURL, uploadString } from "firebase/storage";
import { ref } from "firebase/storage";
import { NextResponse } from "next/server";
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

    const {
      imageUrl,
      roomType,
      style,
      customization,
      userId
    } = await request.json();

    if (!imageUrl || !roomType || !style || !userId) {
      return NextResponse.json(
        { error: "Missing required fields" },
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

    // Get user's email from userId
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

    const userEmail = user[0].email;

    // Check and decrease credits directly
    if ((user[0]?.credits ?? 0) < 1) {
      return NextResponse.json(
        { error: "Insufficient credits" },
        { status: 400 }
      );
    }

    // Decrease credits
    await db
      .update(User)
      .set({
        credits: sql`${User.credits} - 1`
      })
      .where(eq(User.id, parseInt(userId)));

    // Generate the image
    const response = await fetch("https://api.replicate.com/v1/predictions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.REPLICATE_API_TOKEN}`,
        "Content-Type": "application/json",
        "Prefer": "wait"
      },
      body: JSON.stringify({
        version: "76604baddc85b1b4616e1c6475eca080da339c8875bd4996705440484a6eac38",
        input: {
          image: imageUrl,
          prompt: `A ${roomType} with a ${style} style interior ${customization}`
        }
      })
    });

    const result = await response.json();
    console.log("Generated image URL:", result.output);

    // Convert the image to base64
    const base64Image = await convertImageToBase64(result.output);

    // Upload the image to firebase storage
    const fileName = `${new Date().getTime()}.png`;
    const storageRef = ref(storage, 'room_Redesign/'+fileName);
    await uploadString(storageRef, base64Image, "data_url");
    const url = await getDownloadURL(storageRef);
    console.log("Uploaded image URL With AI:", url);

    // Save the image to the database
    const aiGeneratedImage = await db.insert(AiGeneratedImages).values({
      originalImageUrl: imageUrl,
      aiGeneratedImageUrl: url,
      roomType: roomType,
      style: style,
      customization: customization,
      userEmail: userEmail
    }).returning({id: AiGeneratedImages.id});
    
    console.log(aiGeneratedImage[0].id);

    return NextResponse.json({
      message: "Photo generated successfully",
      id: aiGeneratedImage[0].id,
      url: url
    });
  } catch(error) {
    console.error("AI Generation error:", error);
    return NextResponse.json({
      error: "AI Generation failed",
      details: error
    }, { status: 500 });
  }  
}

async function convertImageToBase64(imageUrl: string) {
  const response = await axios.get(imageUrl, {responseType: "arraybuffer"});
  const base64 = Buffer.from(response.data).toString("base64");
  return `data:image/png;base64,${base64}`;
} 