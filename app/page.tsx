import { Button } from "@/components/ui/button";
export default function Home() {
  return (
    <div>
      <h1>Hello World</h1>
      <Button>Click me</Button>
    </div>
  );
}


// app/actions.ts
// "use server";
// import { neon } from "@neondatabase/serverless";

// export async function getData() {
//     const sql = neon(process.env.DATABASE_URL);
//     const data = await sql`...`;
//     return data;
// }