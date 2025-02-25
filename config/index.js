import { drizzle } from "drizzle-orm/neon-http";

const sql = drizzle(process.env.DATABASE_URL);

export default sql;