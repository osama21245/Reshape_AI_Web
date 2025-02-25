import { db } from "@/config/db";
import { storage } from "@/config/firebase";
import { AiGeneratedImages, User } from "@/config/schema";
import axios from "axios";
import { getDownloadURL, uploadString } from "firebase/storage";
import { ref } from "firebase/storage";
import { NextResponse } from "next/server";
import { eq, sql } from "drizzle-orm";

export async function POST(request:Request){
    const {
        imageUrl,
        roomType,
        style,
        customization,
        userEmail
    } = await request.json();

    try {
        // Check and decrease credits directly
        const user = await db
            .select()
            .from(User)
            .where(eq(User.email, userEmail))
            .limit(1);

        if (!user.length || (user[0]?.credits ?? 0) < 1) {
            return NextResponse.json({
                error: "Insufficient credits"
            }, { status: 400 });
        }

        // Decrease credits
        await db
            .update(User)
            .set({
                credits: sql`${User.credits} - 1`
            })
            .where(eq(User.email, userEmail));

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

        //upload the image to firebase storage
        const fileName = `${new Date().getTime()}.png`;
        const storageRef = ref(storage, 'room_Redesign/'+fileName);
       await uploadString(storageRef,base64Image,"data_url");
       const url = await getDownloadURL(storageRef);
       console.log("Uploaded image URL With AI:", url);

       //save the image to the database
       const aiGeneratedImage = await db.insert(AiGeneratedImages).values({
        originalImageUrl: imageUrl,
        aiGeneratedImageUrl: url,
        roomType: roomType,
        style: style,
        customization: customization,
        userEmail: userEmail}).returning({id:AiGeneratedImages.id});
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

async function convertImageToBase64(imageUrl:string){
    const response = await axios.get(imageUrl,{responseType:"arraybuffer"});
    const base64 = Buffer.from(response.data).toString("base64");
    return `data:image/png;base64,${base64}`;
}

