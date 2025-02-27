import { defineConfig } from "drizzle-kit";

export default defineConfig({
    dialect: "postgresql",
    schema: "./src/db/schema.ts",
    out: "./drizzle",
    dbCredentials: {
        host: "db",
        port: 5432,
        database: "mydb",
        user: "postgres",
        password: "test123",
        ssl: false,
    }
});