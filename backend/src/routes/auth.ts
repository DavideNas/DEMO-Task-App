import { Router, Request, Response } from "express";
import { db } from "../db";
import { NewUser, users } from "../db/schema";
import { eq } from "drizzle-orm";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { auth, AuthRequest } from "../middleware/auth";

const authRouter = Router();

interface SignUpBody {
    name: string;
    email: string;
    password: string;
}

interface LoginBody {
    email: string;
    password: string;
}

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
            const hashedPassword = bcrypt.hashSync(password, 8);
            // create a new user and store in db
            const newUser: NewUser = {
                name: name,
                email: email,
                password: hashedPassword,
            };

            const [user] = await db.insert(users).values(newUser).returning();

            // create token like in login
            const token = jwt.sign({ id: user.id }, "passwordKey");

            // DON'T send password to frontend
            const { password: _, ...userWithoutPassword } = user;

            // return response with status code
            res.status(201).json({token, ...userWithoutPassword });
    }catch (e) {
        res.status(500).json({ error: e });
    }
});

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
            // JWT
            const token = jwt.sign({ id: existingUser.id }, "passwordKey");

            const { password: _, ...userWithoutPassword } = existingUser;


            // return response with status code
            res.json({token, ...userWithoutPassword});
    }catch (e) {
        res.status(500).json({ error: e });
    }
});

authRouter.post("/tokenIsValid", async (req, res) => {
    try {
        // get the header
        const token = req.header("x-auth-token");
        
        if(!token) {
            res.json(false); 
            return;
        }

        // verify if the token is valid
        const verified = jwt.verify(token, "passwordKey");

        if(!verified) {
            res.json(false); 
            return;
        }

        // get the user data if the token is valid
        const verifiedToken = verified as {id: string};

        const [user] = await db
            .select()
            .from(users)
            .where(eq(users.id, verifiedToken.id));

        // if no user, return false
        if (!user) {
            res.json(false);
            return;
        }

        res.json(true);
    }
    catch(e) {
        res.status(500).json(false);
    }
});

// localhost:8000/auth/
authRouter.get("/", auth, async (req: AuthRequest, res) => {
    try {
        if(!req.user) {
            res.status(401).json({ msg: "User not found!"});
            return;
        }

        const [user] = await db.select().from(users).where(eq(users.id, req.user));

        // res.json({ ...user, token: req.token });
        const { password: _, ...userWithoutPassword } = user;

        res.json({ ...userWithoutPassword, token: req.token });
    }
    catch(e) {
        res.status(500).json(false);
    }
});

export default authRouter;