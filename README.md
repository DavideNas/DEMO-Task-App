## App flutter with backend
This tutorial explains how to create a mobile app with a BFF pattern implementation
This projects will includes following technologies and packages:

- Flutter,
- BLoC,
- SQLite,
- Postgres,
- Node,
- Express,
- Typescript,
- Docker!

---
### Initial Setup

```sh
mkdir task_app            # create main project folder
cd task_app

flutter create frontend   # create flutter app

cd ..
mkdir backend		          # create folder for backend
```

Then change flutter project boilerplate with following mods:
* remove boilerplate, and add a folder in `/lib/features/auth/pages/`
* then add file `signup_page.dart` : add a stateful widget called **SignupPage** with [this content](<Readme Files/signup_page.md>)
* and `login_page.dart` : add a stateful widget called **LoginPage** with [this content](<Readme Files/login_page.md>)


---

### BACKEND (in NodeJS):

1. Fist step: check **node** and **npm** version
```bash
node --version
npm --version
```

2. Then create node app
```bash
cd backend
npm init -y
```

3. Add a sample file `index.js` with a script: 
```js
console.log("Hello world !")
```

4. Then I make an initial test starting from terminal
```sh
node index.js
```

5. And add some **npm** packages
```sh
npm install express pg drizzle-orm dotenv
```

- `express` used to implement API methods inside a Node app (improving web performance)
- `pg` it's a package which help to connect postgres DB
- `drizzle-orm` used to manage table mapping them as Object Relational Models
- `dotenv` (optional) protect the env file upload (the ones which can contains sensitive data)

6. Install TS directives (and the dependencies optimized to run in NodeJS)
```sh
npm install -D typescript ts-node nodemon @types/node @types/express @types/pg
```

- `typescript` use TS instead of JS 
- `ts-node` enhanced TS package for NodeJS
- `nodemon` tool to make live update
- `@types/...` add all TS suitable types with other libraries (node, express and postgres)

7. Start initial configuration for TS (replacing the JS codebase)
```bash
npx tsc --init
```

8. Then open the `tsconfig.json` file and remove comments:
- `"outDir": "./dist",`, specify output folder (add `dist`)
- `"rootDir": "./src",`, specify source folder for TS files (add `src`)

9. Create a new folder `/src` and a file `index.ts` inside

10. Copy the test script like already done before
```ts
console.log("Hello world!");
```

> Now you must to modify the **"scripts"** parameter to adapt with **nodemon**

11. replace content for "scripts" inside `package.json`
```json
"scripts": {
	"dev": "npx nodemon"
}
```

12. Execute this test
```sh
npm run dev
```
> If some initial `nodemon` settings are missing, the terminal will give an error.

13. To fix this issue add a file `nodemon.json` inside `/backend`
```json
{
	"watch": ["src"],
	"ext": "ts",
	"ignore": ["dist/*"],
	"exec": "ts-node src/index.ts"
}
```

- `watch` define folder to keep watching (excluding other ones)
- `ext` specify extension for starting file
- `ignore` define folder to ignore (to avoid checking from `/dist` and subfolder `/node_modules`)
- `exec` define file to start

1. Restart app 
```sh
npm run dev
```
> Check file update changing and saving log text

---
### CONTAINER SETUP (Docker)

This setup is needed step to implement backend inside Docker container.

This is important to take this advantages:
- A managed ***env*** file
- Deploy app on the server
- Containerize backend app (Node is not auto contained)

1. Download and install Docker Desktop (if not installed)

2. After add a **Dockerfile** named file to `backend/` folder 

3. And setup the container adding this bash commands inside 
```Dockerfile
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8000

CMD ["npm", "run", "dev"]
```

In this file:
- `FROM` define image used inside container
- `WORKDIR` the folder where app is installed
- `COPY` this is used to transfer ROOT content inside WORKDIR (which is `/app`)
- `RUN` used to run packages installation command
- `EXPOSE` to expose container on the port 8000 (for internal use)
- `CMD` used by container to start backend app

4. Next I create a `.dockerignore` adding:
```sh
node_modules/   # this will avoid to check folder
```

---
### APP EXPRESS (NodeJS)

1. Modify the file `src/index.ts`
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

In this file:
- `import ...` is the same JS code `const express = require("express")` for TS
- `const app...` init the app (of type _Express_)
- `app.get...` create a `/` endpoint which will return a simple welcome message
- `app.listen...` define the door to listen

2. Then now I can save the index file and start (if not started yet)
```sh
npm run dev
```

3. from Browser: open the page `localhost:8000`

---
### RUN CONTAINER (Docker)

1. Start Docker Desktop and create the image from terminal
```sh
docker build -t task-backend .
```
In this bash command:
- `-t` is used to define the image name
- `.` at the end, is the folder to containerize (the current one)  

2. Execute docker image
```sh
docker run -p 8080:8000 task-backend
```
In this bash command:
- `-p` used to map the port to listen
- `8080:8000` the syntax is <PORT_HOST>:<PORT_CONTAINER>
	- `PORT_HOST` the port used to access the app from the link (for example `localhost:8080`)
	- `PORT_CONTAINER` defined inside NodeJS with `app.listen` command
	- The `PORT_EXPOSE` for Dockerfile is not mentioned for `run` (used instead in Docker Compose)
- `task-backend` is the name of the image to run

---
### COMPOSE BACKEND (Docker Compose)

1. Create a file `docker-compose.yaml` inside `/src` folder

```yml
services:
  backend:
    build: .
    ports:
      - "8000:8000"
    environment:
      - PORT=8000
      - DATABASE_URL=postgresql://postgres:test123@db:5432/mydb
    depends_on:
      - db
    command: sh -c "npx drizzle-kit push --config=src/drizzle.config.ts && npm run dev"
  db:
    image: postgres:15
    container_name: postgres_container
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=test123
      - POSTGRES_DB=mydb
    ports:
      - "5432:5432"
```
Tips: 
> Never use volume for `node_module` risks creating an empty folder returning strange errors
> Exploit the `package.json` file copied inside `Dockerfile`

2. Then start Docker Compose:
```sh
docker compose up --build
```
> In each compose mod disable container (before each restart):

3. To disable containers:
```sh
docker compose down     # Deactivate/Remove containers and managed Docker Compose Network

# OTHER COMMANDS
docker compose down -v  # Remove also Volumes (when declared inside docker-compose file)
docker compose down --rmi all   # Remove also the images created by compose
docker compose down --rmi local # Or only build images
docker system prune -a --volumes    # Brutal clean (of all containers + volumes + images)
```

---
### DB CONNECTION (SQLite + Node)

Add a config file for DB 

1. Create a new file in `/src/db/index.ts`

2. Then write in this code:
```ts
import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";

const pool = new Pool({
    connectionString: "postgresql://postgres:test123@mydb:5432/mydb"
});

export const db = drizzle(pool);
```
> This script define connection between ORM and backend by reading DB through `connectionString`

---
### ROUTING (Node)

1. To set new auth page create a file `/src/routes/auth.ts`

2. Then add this content:
```ts
import { Router } from "express";

const authRouter = Router();

authRouter.get("/", (req, res) => {
	res.send("Hey there! from auth");
});

export default authRouter;
```
> The full endpoint is determined by the folder structure + the path specified in `authRouter.get()`

3. Modify `/src/index.ts` file adding middleware

4. Add initial routing script as following
```ts
[...]
import authRouter from "./routes/auth";

const app = express();

app.use(express.json());
app.use("/auth", authRouter);
```
In this snippet:
- `app.use(express.json())` check the initial file type (set as `.json`)
- `app.use("/auth", authRouter)` create a route inside `/auth` page

---

### ORM (Node + Drizzle)

1. Create a file for ORM in `/src/db/schema.ts`

2. Adding this content:
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

In this code snippet:
- **User** is the type to execute SQL and DML for users DB table
- **User** is used to read **users** from DB
- **NewUser** is used to write new users to BD

3.  Add new route to the `src/routes/auth.ts` file
```ts
// Firstly add needed imports
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";

// and create interface
interface SignUpBody {
    name: string;
    email: string;
    password: string;
}

// [...]
// Next create new route for new user registration
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
                    .json({ msg: "User with the same email already exists!" });
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

4. Before go further with password decode install other packages
```sh
npm i bcryptjs
npm i -D @types/bcryptjs
```

5. Next add import to the file
```ts
import bcryptjs from "bcryptjs";

// [...]
// and the missing block

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
> The block must insert in the same `src/routes/auth.ts` snippet

6. Install also dev package
```sh
npm i -D drizzle-kit
```

7. Add a config DB file `src/drizzle.config.ts`

8. With following content
```ts
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

> This create a schema for postgres DB which will be applied during runtime via drizzle migration

---
### IMPORTANT CHANGES (typescript + env + docker-compose)
To config all some important changes must be made
- The `schema.ts` will be added to `src/db/` path, then I must to say also to `drizzle.config.ts` file
- In the `docker-compose.yml` 
	- url will be updated modifying the @db host reference (which will refer to postgres container)
	```sh
	environment:
		- PORT=8000
		- DATABASE_URL=postgresql://postgres:test123@db:5432/mydb
	```

- Dockerfile contains some modifications :
	- fix versioning fot npm packages to make them compatible with linux system inside container
	- for `esbuild` update the version based on OS
	```Dockerfile
	RUN apt-get update && apt-get install -y \
    build-essential \
    esbuild
  ```
    
  - When I need to make migration I must to check the postgres container is charged and active 
    To do I can add to container a custom script `wait-for-it`
  ```Dockerfile
  COPY wait-for-it.sh /usr/local/bin/wait-for-it
	RUN chmod +x /usr/local/bin/wait-for-it
	```

- The script 'wait-for-it' it's a standard for perfect sync of containers
	- download file from main `/backend` app folder
	```sh
	curl -o wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
	```
	- update (exec) permissions
	```sh
	chmod +x wait-for-it.sh
	```

---
### CHECK THE DB (docker-compose)

1. Start `docker-compose`
```sh
docker compose up --build
```

2. Open Docker Desktop client and select Postgres Container, then select EXEC tab
  - I can do the same thing from terminal:
  I. reading the postgres container id with `docker ps`
  II. Copying the <code-container>
  III. And writing into `docker exec -it <code-container> sh`

3. Open DB prompt
```sh
psql -U postgres -d mydb
```

4. Verify the DB tables
```sh
\dt
```

5. Check content with a select on the users table
```sql
SELECT * FROM users;
```

---
### TEST SIGNUP (Postman | ThunderClient)
To start the new user creation you can send some POST requests.

You can do them with `Postman` (downloading the client) or directly form VSCode with `Thunder Client` extension.

***With ThunderClient :***
1. To use `Thunder Client` you must to click on `New Request`.
2. insert the url `http://localhost:8000/auth/signup`
3. Change request verb on `POST`
4. And choose the `Body` tab adding this json code
```json
{
  "name": "dave",
  "email": "pirate@dave.com",
  "password": "test123"  
}
```
> If it's OK, you will get a message `Status: 201 Created` and a `Response` structured on the right with all fields on the table

---
### LOGIN PAGE (TypeScript)

1. Add to `src/routes/auth.ts` file an interface for the login
```ts
interface LoginBody {
    email: string;
    password: string;
}
```

2. And the new login function
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
### TEST LOGIN  (Postman | ThunderClient)

1. Create new POST request in `Thunder Client`
2. Ad path url write `http://localhost:8000/auth/login`
3. Change the request verb to POST
4. Then add to the json body the login attributes
```json
{
  "email": "pirate@dave.com",
  "password": "test123"  
}
```
> If all is correct I will get a response `Status: 200 OK` with a json in the `Response` tab with user data:

---
### JWT (Typescript + node)

To have a secure user connection you can implement JWT module.

1. Shut-Down the `docker-compose`
```sh
docker-compose down -v
```

2. Install new packages and types for JWT
```sh
npm i jsonwebtoken
npm i -D @types/jsonwebtoken
```

3. And restart the `docker-compose`
```sh
docker compose up --build
```

4. Modify the `src/routes/auth.ts` file
```ts
import jwt from "jsonwebtoken";
```

5. And inside the login function (before the `res.json`)
```ts
// JWT
const token = jwt.sign({ id: existingUser.id }, "passwordKey");
```

6. Run again the request from `Thunder Client` and if it's OK I'll get a response as json with `token` and the user data
> Copy the string `token` for the next step

---
### VERIFY JWT (Postman | Thunder Client)

1. To get validation of JWT you can run a new `Thunder Client` request with this parameters:

- VERB: POST
- URL: 	http://localhost:8000/auth/tokenIsValid
- HEADER: x-auth-token
- HEADER: <paste the previous token>
- BODY: keep it void

2. Click SEND to get a Response = 'true'
> The catch event will is trig with a json = false, then try to change the token to test error case with a Response = 'false'

---
### GET USER DATA
When you finish the token verify process, I need to retrieve user data (that will be sent to frontend)  
To do I need to allow the "/" route to visualize this data  
A key point for data retrieve is the middleware integration  
The middleware is the part that will permit only a specific users to make some actions  
For example you can permit some action only for the authenticated users

***An Overview :***
- The first step is to verify if an user is authenticated or not
- The middleware integration will route each request to a specific endpoint
- Middleware exploit the function `tokenIsValid`

1. I create new folder and file in `src/middleware/auth.ts`
2. Add this content:
```ts
import { UUID } from "crypto";
import { eq } from "drizzle-orm";
import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { users } from "../db/schema";
import { db } from "../db";

export interface AuthRequest extends Request {
    user?: UUID;
    token?: string;
}

export const auth = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        // get the header
        const token = req.header("x-auth-token");
        
        if(!token) {
            res.status(401).json({ msg: "No auth token, access denied!"}); 
            return;
        }

        // verify if the token is valid
        const verified = jwt.verify(token, "passwordKey");

        if(!verified) {
            res.status(401).json({msg: "Token verification failed!"}); 
            return;
        }

        // get the user data if the token is valid
        const verifiedToken = verified as {id: UUID};

        const [user] = await db
            .select()
            .from(users)
            .where(eq(users.id, verifiedToken.id));

        // if no user, return false
        if (!user) {
            res.status(401).json({msg: "User not found!"}); 
            return;
        }

        req.user = verifiedToken.id;
        req.token = token;
        next();
    }
    catch(e) {
        res.status(500).json(false);
    }
}
```

Some feature form this snippet:
- `interface` it's a `Request` extension, will return only `user` and `token`
- `NextFunction` allow the middleware integration in the main `/auth` root
- The **_try_** and **_catch_** block is get from previous `tokenIsValid` block
- `res.status` return an error code for each case
- `verifiedToken` is an UUID type (not `string`)

Then I can integrate the `src/routes/auth.ts` file
3. Update the `authRouter.get` function adding the `auth` middleware and changing the response with a `req.token`
```ts
authRouter.get("/", auth, (req: AuthRequest, res) => {
    res.send(req.token);
});
```

4. Add the needed imports
```ts
import { auth, AuthRequest } from "../middleware/auth";
```

5. As the code is finish the test step can begin with `Thunder Client`
Create a new request with this values:
- URL: http://localhost:8000/auth/
- VERB: GET
- HEADER: x-auth-token
- HEADER CONTENT: <the token from login>

If the request it's OK I'll get a token as response, the same of the one entered in the header.

6. As last step to get the user data you must to update the content in the "/" endpoint for the `src/routes/auth.ts` file

- From this:  
```ts
authRouter.get("/", auth, (req: AuthRequest, res) => {
    res.send(req.token);
});
```


- To this:
```
authRouter.get("/", auth, async (req: AuthRequest, res) => {
    try {
        if(!req.user) {
            res.status(401).json({ msg: "User not found!"});
            return;
        }

        const [user] = await db.select().from(users).where(eq(users.id, req.user));

        res.json({ ...user, token: req.token });
    }
    catch(e) {
        res.status(500).json(false);
    }
});
```
> You can see how the function it become async, this is needed to synchronize user info to forward them to the response

---
### CONNECT FRONTEND (flutter)

Now that I have return user data from backend I can connect frontend mobile (flutter).

1. But before going next I need to install 2 new packages:
```sh
dart pub add http   # for http
flutter pub add flutter_bloc  # flor BLoC integration
```

2. Next create new folder in `lib/features/auth/repository`

3. This folder will contains 2 files:
- **AuthRemote Repository**: To communicate with external API (in NodeJS)
- **LocalAuth Repository**: To create a offline-first app.

4. Create the first `auth_remote_repository.dart` file
```dart
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/signup',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
		body: jsonEncode({
					'name': name,
					'email': email,
					'password': password
				}),
      );
      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['msg'];
      }

      //return UserModel.fromMap(jsonDecode(res.body));
      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }
	// Future<void> login({}) {	}
}
```
From this snippet:
- `backendUri` is a const variable defined in a separated file (look below).
- `UserModel` is the referral model defined below 
- `UserModel.fromJson` will be implemented once the mapping code will be created inside the model file
- `UserModel.fromMap` this is useful when I want to separate class tasks removing `toJson` and `fromJson` method
- `body` contains response vars

Variables implemented in http requests are created as const

5. Then add new file in `lib/core/constants/constants.dart`
```dart
class Constants {
	static String backendUri = "http://localhost:8000";
}
```

---
### MODEL USER

Create new file `lib/models/user_model.dart`
```dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;
};
```

Once the fields are implemented in the user model, I must to make a mapping to convert it from and to the json format  
In VSCode you can do with a plugin : `Dart Data Class Generator`
You can install the plugin and create the rest of the code for the mapping with:
- Click Right on the model code > Choose "Generate data class"
- This will create a new portion code for mapping model fields

---
### CUBIT
Cubit become from BLoC FrameWork that come between the repository and the app view  
It's useful to set an observer pattern between repositories (which retrieve data from backend) and the frontend components

> `part` and `part of` is used to connect 2 files to get an information matching

Start creating 2 files :

1. The first `lib/features/auth/cubit/auth_state.dart` 
2. With this code inside:
```dart
part of "auth_cubit.dart";

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSignUp extends AuthState {}

final class AuthLoggedIn extends AuthState {
  final UserModel user;
  AuthLoggedIn(this.user);
}

final class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}
```

- `AuthState` is the class which unites the State Methods
- `AuthInitial` extends `AuthState` and makes the State Object initializable (from other classes)

3. The second `lib/features/auth/cubit/auth_cubit.dart`
4. With this content
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      //final userModel =
      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      // emit(AuthLoggedIn(userModel));
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

- `AuthCubit` defines the Cubit class which will get the Change of State from `AuthState`
- Next line is used to init Cubit class (with `AuthInitial` State)
- `authRemoteRepository` instantiate a repository's copy to "observe"
- `signUp` is a method (like an action) which modify the login state
- `emit(...)` describe the current state which will be modified during code exec

Now you can implement Cubit pattern in `lib/main.dart` file  
Before proceed I need to add a VSCode component to create widget  
5. Then from Extension TAB of VSCode I search `bloc` (of Felix Angelov) and install it

Add then the widget to `MaterialApp` with `CTRL + .` to open menu and 
6. select `BlocProvider`
7. update name in `MultiBlocProvider`
8. remove `create` label
9. add `providers` label
```dart
providers: [
	BlocProvider(create: (_) => AuthCubit()),
],
```
> `BlocProvider` connect the widget to `AuthCubit` class

10. Now modify the `lib/features/auth/signup_page.dart` file adding the read data method
```dart
void signUpUser() {
	if (formKey.currentState!.validate()) {
		// store the user data
    context.read<AuthCubit>().signUp(
			name: nameController.text.trim(),
			email: emailController.text.trim(),
			password: passwordController.text.trim(),
		);
	}
}
```
In this snippet:
- `context.read` call the `signUp` action holds by Cubit
- The values `name`, `email` and `password` are taken from `Controller` components
- Params are "trimmed" or compressed from void spaces in the string

Then apply the bloc pattern state to the body page (still in `signup_page`)  
11. Make a wrap for `Padding` component with the shortcut `CTRL + .` choosing `BlocConsumer`

12. Modify the component as follow:
```dart
BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          } else if (state is AuthSignUp) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account created! Login NOW!"),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
```
In this snippet:
- `AuthCubit` is the State emitter
- `AuthState` is the class which define the State
- `AuthError` to visualize an error message via SnackBar
- `AuthLoading` to create a circular progress component
- `AuthSignUp` to visualize a message of registration done via SnackBar

---
### CHECK FULL APP

Check now all write steps on Postgres DB once the registration is complete  
This process is possible modifying the IP address which will recall the backend of Flutter app
- If it's running on local emulator `10.0.2.2:8000`
- If it's running on a physical Android device the IP must be the same the one that execute Docker client (check with `ipconfig`)

Start all with 
1. `docker compose up --build` from terminal `/backend`
2. `flutter run` from terminal `/frontend`
3. Open the page `signup` from Android app
4. Insert registration credentials
5. Press `Signup` button
6. From PC open Docker Desktop client and select Postgres container
7. Choose the EXEC tab to write at the postgres terminal
8. Write `psql -U postgres -d mydb` to open the DB
9. Make a simple `SELECT * FROM users;` to read user list (It should be what you entered from the Flutter page on Android)
---
