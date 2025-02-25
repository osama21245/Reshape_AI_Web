import { NextResponse } from "next/server";
import {db} from "@/config/db";
import { User } from "@/config/schema";
import { eq } from "drizzle-orm";
export async function POST(request:Request){
    const {user} = await request.json();


    try {
        //if user already exists, return the user info
        const userInfo = await db.select().from(User).where(eq(User.email,user.primaryEmailAddress?.emailAddress));
        if(userInfo.length > 0){
            console.log("Existing user found:", userInfo[0]);
            return NextResponse.json({
                result:userInfo[0]
            })
        }
        //if user does not exist, create a new user
        if(userInfo.length === 0){
            const newUser = await db.insert(User).values({
                name:user.fullName,
                email:user.primaryEmailAddress?.emailAddress,
                image:user.imageUrl,
            }).returning();
            console.log("New user created:", newUser[0]);
            return NextResponse.json({
                result:newUser[0]
            })
        }
      
    }catch(error){
        console.error("Database error:", error);
        return NextResponse.json({
            error: "Database error",
            details: error
        }, { status: 500 });
    }

  
    
    
}