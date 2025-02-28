## App flutter con backend 
Questo tutorial spiega come creare un'app mobile con un backend in NodeJS.
Include le seguenti tecnologie e pacchetti:

- Flutter,
- BLoC,
- SQLite,
- Postgres,
- Node,
- Express,
- Typescript,
- Docker!

---
### Setup Iniziale
```bash
mkdir task_app
cd task_app
```

---
## FRONTEND (flutter):

→ Creo il frontend in flutter
```bash
flutter create frontend
```
→ Torno alla cartella task_app
```bash
cd ..
mkdir backend		
```

→ Poi accedi all'app flutter e rimuovi il boilerplate, quindi crea una cartella in 
`/lib/features/auth/pages/`

→ quindi aggiungo un file 
`signup_page.dart`
e 
`login_page.dart`

→ creo il boilerplate del widget stateful in flutter e lo rinomino
stf → SignupPage

→ Con una struttura pari alla pagina
https://github.com/DavideNas/Task-App/blob/main/frontend/lib/features/auth/pages/signup_page.dart

stf → LoginPage
con una struttura pari alla pagina:
https://github.com/DavideNas/Task-App/blob/main/frontend/lib/features/auth/pages/login_page.dart

Leggi il codice dalla versione ["First Commit : basic flutter pages"](<https://github.com/DavideNas/Task-App/commit/0d7e3492fdb70ac437961fb0d3191588ec0b18cc>)

---
## BACKEND (node):
→ Prima di iniziare installa nodejs ed npm verificando la versione: 
```bash
node --version
npm --version
```
→ Quindi crea l'app node
```bash
cd backend
npm init -y
```
---
### Test node
→ Creo un file di prova `index.js` con uno script 
```js
console.log("Hello world !")
```
→ Quindi faccio un test iniziale avviandolo da terminale
```bash
node index.js
```
→ Quindi installo alcuni pacchetti tramite npm
```
npm install express pg drizzle-orm dotenv
```
- `express` è un pacchetto che migliora le prestazioni di app web/mobile fornendo metodi API
- `pg` è un pacchetto che aiuta a connettere il DB postgres
- `drizzle-orm` gestisce la mappatura delle tabelle come oggetti relazionali
- `dotenv` (opzionale) protegge l'upload di file env che potrebbero contenere dati sensibili

→ Installo le direttive di TS (e le dipendenze ottimizzate per eseguirlo in node)
```
npm install -D typescript ts-node nodemon @types/node @types/express @types/pg
```
- `typescript` utilizzo di TS anziché JS
- `ts-node` pacchetto di ottimizzazione TS su NODE
- `nodemon` tool per il live refresh degli script
- `@types/...` aggiunge i tipi TS compatibili con le varie librerie (node, express e postgres)

→ Avvio la configurazione iniziale di TS (sostituendolo a JS come codice di base)
```bash
npx tsc --init
```
→ Quindi apro il file "tsconfig.json" e decommento
`"outDir": "./dist",` , specifica la cartella di output (aggiungo `dist`)
`"rootDir": "./src",` , specifica la cartella sorgente per i file TS (aggiungo `src`)

→ Creo una cartella `/src` ed un file al suo interno `index.ts`

→ Copiando il test script di prima
```ts
console.log("Hello world!");
```

> Adesso però prima di avviare modifico il parametro "script" per impostarlo con nodemon

→ Sostituisco il contenuto del la label "scripts" in `package.json`
```json
"scripts": {
	"dev": "npx nodemon"
}
```
Test di prova:
```bash
npm run dev
```
> Mancando alcune impostazioni iniziali di `nodemon` il terminale darà errore.

→ Correggo aggiungendo un file `nodemon.json` nella cartella principale di `/beckend`
```json
{
	"watch": ["src"],
	"ext": "ts",
	"ignore": ["dist/*"],
	"exec": "ts-node src/index.ts"
}
```
- `watch` definisce la cartella presa in esame (e nessun altra)
- `ext` specifica l'estensione del file di avvio
- `ignore` specifica le cartelle da ignorare (evitando di pescare info da `/dist` e sottocartelle come `/node_modules`)
- `exec` definisce il file da avviare

→ Riavvio l'app 
```bash
npm run dev
```
> verifico l'aggiornamento del file modificando il testo del log e salvandolo subito dopo

---
### DOCKER

Il passaggio successivo consiste nell'installare Docker per utilizzarlo nel beckend

Questo è fondamentale per avere i seguenti vantaggi
1. Un env. controllato
2. Distribuire l'app su server
3. Contenerizzare l'app beckend (Node non è auto-contenerizzato)

→ Scarico ed installo il software se non presente

→ In seguito aggiungo un nuovo file alla cartella `backend/`
`Dockerfile`

→ Quindi creo il setup della VM 
```bash
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8000

CMD ["npm", "run", "dev"]
```
- `FROM` definisce l'immagine da usane nel container
- `WORKDIR` la cartella dove l'app viene installata
- `COPY` il comando che trasferisce il contenuto nella cartella ROOT in WORKDIR (ovvero `/app`)
- `RUN` usato per installare i pacchetti necessari
- `EXPOSE` per esporre il contenitore alla porta 8000 (uso prettamente interno)
- `CMD` comandi di avvio usati dal container per far girare l'app


→ Quindi creo un `.dockerignore` aggiungendo:
```
node_modules/
```
---
### APP EXPRESS
Modifico il file `src/index.ts`
```ts
import express from "express"
const app = express();

app.get("/", (req, res) => {
	res.send("Welcome to my app!");
});

app.listen(8000, () => {
	console.log("Server started on port 8000");
});
```
- `import ...` equivale a codice JS `const express = require("express")` rendendolo però compatibile con TS
- `const app...` inizializzo l'app (di tipo _Express_)
- `app.get...` crea un endpoint base `/` che restiruisce una semplice frase di benvenuto
- `app.listen...` definisce la porta in ascolto sull'app

→ Quindi adesso posso salvare il file index ed avviarlo (se non è già avviato)
```bash
npm run dev
```

**_DA BROWSER_**
→ apro la pagina `localhost:8000`

---
### DOCKER IMAGE
→ Avvio Docker Desktop e creo l'immagine da terminale
```bash
docker build -t task-backend .
```
- `-t` è usato per definire il nome dell'immagine
- `.` alla fine è la cartella da contenerizzare (quella attuale del progetto)  

→ Eseguo l'immagine docker
```
docker run -p 8080:8000 task-backend
```
- `-p` serve a mappare le porte in ascolto
- `8080:8000` la sintassi è <PORTA_HOST>:<PORTA_CONTAINER>
	- `PORTA_HOST` è la porta che serve ad accedere all'app tramite link (ad esempio `localhost:8080`)
	- `PORTA_CONTAINER` è definita nell'app node in `app.listen`
	- La `PORTA_EXPOSE` del Dockerfile non viene menzionata dal `run` (usata invece in Docker Compose)
- `task-backend` è il nome dell'immagine da avviare

---
### DOCKER COMPOSE
→ Creo un file dockercompose nella cartella `/src`:
`docker-compose.yml`

```yml
services:
	backend:
		build:
			context: ./
		ports:
			- "8000:8000"
		environment:
			- PORT=8000
			- DATABASE_URL=postgresql://postgres:test123@mydb:5432/mybd
		depends_on:
			- db
		volumes:
			- ./:/app
	db:
		image: postgres:15
		container_name: postgres_container
		restart: always
		environment:
			POSTGRES_USER=postgres
			POSTGRES_PASSWORD=test123
			POSTGRES_DB=mydb
		ports:
			- "5432:5432"
```
> Non utilizzare il volume per `node_module` rischia di creare una cartella vuota restituendo errori strani
> Sfruttare la copia di `package.json` direttamente nel `Dockerfile`

→ Quindi avvio il compose di Docker
```
docker compose up --build
```
> Ad ogni modifica del compose disattivo il contenitore (prima della ri-attivazione):

→ Disattivo i contenitori:
```
docker compose down
```

---
### DB CONNECTION
Aggiungo il file di configurazione del DB 

→ Creo un file in `/src/db/index.ts`

→ Quindi scrivo il codice:
```ts
import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";

const pool = new Pool({
    connectionString: "postgresql://postgres:test123@mydb:5432/mydb"
});

export const db = drizzle(pool);
```
Questo script configura l'ORM con il backend di node leggendo il DB tramite `connectionString`

---
### ROUTING

→ Per impostare una nuova pagina per le autorizzazioni creo un file `/src/routes/auth.ts`

→ Col contenuto
```ts
import { Router } from "express";

const authRouter = Router();

authRouter.get("/", (req, res) => {
	res.send("Hey there! from auth");
});

export default authRouter;
```
> il percorso per aprire questa pagina è definito tramite la struttura delle cartelle + la stringa definita `authRouter.get`

→ Modifico poi il file `/src/index.ts` aggiungendo dei middleware

→ Aggiungo il routing all'inizio dello script come segue
```ts
[...]
import authRouter from "./routes/auth";

const app = express();

app.use(express.json());
app.use("/auth", authRouter);
```

- `app.use(express.json())` controlla il tipo di file in entrata (che deve essere un `.json`)
- `app.use("/auth", authRouter)` crea una route sulla pagina `/auth`

---
### ORM
→ Creo quindi un file per l' ORM in `/src/db/schema.ts`

Col contenuto
```ts
import { pgTable, text, uuid, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
	id: uuid("id").primaryKey().defaultRandom(),
	name: text("name").notNull(),
	email: text("email").notNull().unique(),
	password: text("password").notNull(),
	createdAt: timestamp("created_at").defaultNow(),
	updatedAt: timestamp("updated_at").defaultNow(),
});

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
```

Questo schema definisce il tipo User per la select e l'insert di nuovi users a db.
- User è utilizzato per leggere gli utenti da DB
- NewUser è usato per scrivere i nuovi utenti a BD

→ Aggiungo una nuova rotta al file `src/routes/auth.ts`
→ Aggiungo gli import necessari
```ts
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";
```

→ Creo un'interfaccia
```ts
interface SignUpBody {
    name: string;
    email: string;
    password: string;
}
```

→ Quindi creo una nuova rotta per la registrazione di un nuovo utente
```ts
authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    try {
        // get req body
        const {name, email, password} = req.body;
        // check if the user already exists
        const existingUser = await db
            .select()
            .from(users)
            .where(eq(users.email, email));
        
            if(existingUser.length) {
                res
                    .status(400)
                    .json({ msg: "User with the same email alreasy exists!" });
                return;
            }
        // hash pw
            // added in next step
        // create a new user and store in db
            // added in next step
        // return response with status code
    }catch (e) {
        res.status(500).json({ error: e });
    }
});
```

prima di proseguire con la codifica della password installo altre librerie a terminale
```bash
npm i bcryptjs
npm i -D @types/bcryptjs
```
→ Quindi aggiungo l'import al file
```ts
import bcryptjs from "bcryptjs";
```
→ Ed aggungo il blocco mancante
```ts
// hash pw
const hashedPassword = await bcryptjs.hash(password, 8);
// create a new user and store in db
const newUser: NewUser = {
	name: name,
	email: email,
	password: hashedPassword,
};

const [user] = await db.insert(users).values(newUser).returning();
// return response with status code
res.status(201).json(user);
```
> il blocco va inserito nello stesso script del file `src/routes/auth.ts`

```
npm i -D drizzle-kit
```

→ Aggiungo un file di configurazione del DB `src/drizzle.config.ts`
→ Col contenuto
```
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
```

> Questo crea uno schema per il Database postgres che sarà applicato in runtime tramite migrazione drizzle

---
### MODIFICHE IMPORTANTI
Per configurare il tutto ed effettuare una serie di modifiche importanti

- Lo `schema.ts` viene aggiunto dal path `src/db/` quindi devo dirlo anche nel file `drizzle.config.ts`
- Il `docker-compose.yml` 
	1. l'url viene aggiornato modificando il riferimento all'host @db (che fa riferimento al container postgres)
	```bash
	environment:
		- PORT=8000
		- DATABASE_URL=postgresql://postgres:test123@db:5432/mydb
	```
	2. in fondo alla configurazione `beckend` aggiungo lo script
	```bash
	command: ["sh", "-c", "wait-for-it db:5432 -- npx drizzle-kit push --config src/drizzle.config.ts && npm run dev"]
	```
	che mi serve ad avviare la migrazione drizzle applicando un file `wait-for-it` per attendere il caricamento del container `postgres`
- Il Dockerfile contiene delle aggiunte che :
	1. correggo il versionamento dei pacchetti npm in modo che siano compatibili con il sistema linux che gira nel container
	`esbuild` aggiorna la versione in base al sistema operativo
	```bash
	RUN apt-get update && apt-get install -y \
    build-essential \
    esbuild
    ```
    2. avendo bisogno di fare la migrazione devo assicurarmi che il contenitore postgres sia caricato ed attivo. 
    Per farlo aggiungo al container lo script `wait-for-it`
    ```
    COPY wait-for-it.sh /usr/local/bin/wait-for-it
	RUN chmod +x /usr/local/bin/wait-for-it
	```
- lo script wait-for-it è fondamentale per la perfetta sincronizzazione dei contenitori.
	1. scarico il file dalla cartella principale dell'app `/beckend`
	```
	curl -o wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
	```
	2. modifico i permessi
	```
	chmod +x wait-for-it.sh
	```

---
### CHECK DEL DB

→ Avvio il `docker-compose`
```bash
docker compose up --build
```
> se dovessi ricompilare il tutto per correggere errori posso eliminare i container con `docker system prune -a`

#### METODO 1:
→ Poi apro l'app Docker desktop e seleziono il container Postgres poi la tab EXEC
#### METODO 2:
→ Posso fare la stessa cosa da terminale leggendo il codice del container postgres
```bash
docker ps
```
→ Copio il <codice-container> poi lo scrivo nel comando
```bash
docker exec -it <codice-container> sh
```

#### Accedo al prompt del db
```bash
psql -U postgres -d mydb
```

#### verifico la presenza di tabelle
```bash
\dt
```

#### faccio una select sulla tabella users
```sql
SELECT * FROM users;
```
---
### TEST SIGNUP
Per iniziare a creare un nuovo utente è possibile inviare alcune POST request.
Si può fare con `Postman` (scaricando il client) o direttamente da VSCode tramite `Thunder Client`

→ Se usi `Thunder Client` basta cliccare su `New Request`.
→ Quindi inserisci l'url
http://localhost:8000/auth/signup
→ E metti il verbo su `POST`
→ Poi scegli la tab `Body` ed aggiungi il seguente codice json
```json
{
  "name": "dave",
  "email": "pirate@dave.com",
  "password": "test123"  
}
```
> Se tutto va liscio ricevi il messaggio `Status: 201 Created` ed una `Response` strutturata a destra con i vari campi della tabella.

---
### LOGIN PAGE

→ Aggiungo la pagina di login al file `src/routes/auth.ts` creo un'interfaccia per la login
```ts
interface LoginBody {
    email: string;
    password: string;
}
```
→ Quindi la funzione di login
```ts
authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
    try {
        // get req body
        const { email, password } = req.body;
        // check if the user already exists
        const [existingUser] = await db
            .select()
            .from(users)
            .where(eq(users.email, email));
        
            if(!existingUser) {
                res.status(400).json({ msg: "User with this email does not exists!" });
                return;
            }
            // hash pw
            const isMatch = bcrypt.compareSync(password, existingUser.password);
            if(!isMatch) {
                res.status(400).json({ msg: "Incorrect password!" });
                return;
            }

            // return response with status code
            res.json(existingUser);
    }catch (e) {
        res.status(500).json({ error: e });
    }
});
```

---
### TEST LOGIN

Come per la registrazione creo una nuova POST request tramite `Thunder Client`

→ Questa volta aggiungo il path url `http://localhost:8000/auth/login`
→ Sceglo il verbo della richiesta POST
→ Quindi aggiungo al bodi il codice json per il login
```json
{
  "email": "pirate@dave.com",
  "password": "test123"  
}
```
> Se tutto va bene ottterrò una risposta `Status: 200 OK` con un json nella tab `Response` contenente i dati utente.
---
### JWT
Per assicurarsi che l'utente abbia una connessione sicura è possibile implementare il modulo JWT.
→ Spegnendo il docker-compose con
```bash
docker-compose down -v
```
→ Installo il nuovo pacchetto JWT ed i tipi associati (per TS)
```bash
npm i jsonwebtoken
npm i -D @types/jsonwebtoken
```
→ Quindi riavvio il docker-compose
```bash
docker compose up --build
```

Modifico poi il file `src/routes/auth.ts`
```ts
import jwt from "jsonwebtoken";
```
→ Quindi nella funzione di login (prima del `res.json`)
```ts
// JWT
const token = jwt.sign({ id: existingUser.id }, "passwordKey");
```

→ Rieseguo la richiesta di login con `Thunder Client` ed se tutto va bene ottengo un file json con il `token` ed i dati dell'utente
> Copio la stringa `token` per lo step successivo

---
### VERIFY JWT
Per la verifica del JWT eseguo una nuova Richiesta `Thunder Client` con queste specifiche:

- VERB: 	POST
- URL: 	http://localhost:8000/auth/tokenIsValid
- HEADER: x-auth-token
- ARGOMENTO HEADER: <il token copiato prima>
- BODY: lasciare vuoto

