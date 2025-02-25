import { pgTable,varchar,serial,timestamp,integer} from "drizzle-orm/pg-core";

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

