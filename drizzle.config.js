import 'dotenv/config';
import {defineConfig} from "drizzle-kit";

export default defineConfig({
    dialect: "postgresql",
    schema: "./config/schema.js",
    
        dbCredentials: {
           url: process.env.DATABASE_URL                
    },
});
