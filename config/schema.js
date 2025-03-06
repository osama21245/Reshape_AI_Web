import { pgTable,varchar,serial,timestamp,integer,text,boolean } from "drizzle-orm/pg-core";

export const User =pgTable("users",{
    id: serial("id").primaryKey(),
    name: varchar("name",{length:255}).notNull(),
    email: varchar("email",{length:255}).notNull().unique(),
    image: varchar("image").notNull(),
    createdAt: timestamp("created_at").notNull().defaultNow(),
    updatedAt: timestamp("updated_at").notNull().defaultNow(),
    credits: integer("credits").default(3),
})


export const AiGeneratedImages = pgTable("ai_generated_images",{
    id: serial("id").primaryKey(),
    originalImageUrl: varchar("originalImageUrl").notNull(),
    aiGeneratedImageUrl: varchar("aiGeneratedImageUrl").notNull(),
    roomType: varchar("roomType").notNull(),
    style: varchar("style").notNull(),
    customization: varchar("customization"),
    userEmail: varchar("userEmail").notNull(),
    createdAt: timestamp("created_at").notNull().defaultNow(),
    updatedAt: timestamp("updated_at").notNull().defaultNow(),
})

// New tables for QR code login functionality
export const AuthToken = pgTable("auth_tokens", {
    id: serial("id").primaryKey(),
    userId: integer("user_id").notNull(),
    token: varchar("token", { length: 255 }).notNull().unique(),
    expiresAt: timestamp("expires_at").notNull(),
    isUsed: boolean("is_used").default(false),
    createdAt: timestamp("created_at").notNull().defaultNow(),
})

export const DeviceLogin = pgTable("device_logins", {
    id: serial("id").primaryKey(),
    userId: integer("user_id").notNull(),
    deviceName: varchar("device_name", { length: 255 }).notNull(),
    deviceLocation: text("device_location"),
    tokenId: integer("token_id").notNull(),
    lastLoginAt: timestamp("last_login_at").notNull().defaultNow(),
    createdAt: timestamp("created_at").notNull().defaultNow(),
    isActive: boolean("is_active").default(true),
})

