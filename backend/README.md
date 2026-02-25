If needed run this command to generate correct config file for drizzle migrations: 
```sh
npx drizzle-kit generate --config=src/drizzle.config.ts
```

The restart Docker Compose rebuilding new images (After starting Docker Desktop)
```sh
docker compose up --build
```

