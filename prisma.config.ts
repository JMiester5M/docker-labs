import "dotenv/config";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    // Prisma 7: use process.env here so commands like `prisma generate`
    // don't fail if DATABASE_URL is missing (e.g., in CI or during Docker builds).
    // At runtime, this should be set via .env / deployment env vars.
    url: process.env.DATABASE_URL ?? "",
  },
});
