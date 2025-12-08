import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { storage } from '../services/storage';
import { AuthRequest } from '../middleware/auth';

export async function getUserById(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const user = await storage.getUserById(id);

    if (!user) {
      res.status(404).json({
        success: false,
        code: 404,
        message: 'User not found',
      });
      return;
    }

    res.json(user.toResponse());
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

export async function getAllUsers(req: Request, res: Response): Promise<void> {
  try {
    const users = await storage.getAllUsers();
    res.json(users.map(user => user.toResponse()));
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

export async function createUser(req: Request, res: Response): Promise<void> {
  try {
    const { email, password, name } = req.body;

    if (!email || !password) {
      res.status(400).json({
        success: false,
        code: 400,
        message: 'Email and password are required',
      });
      return;
    }

    const existingUser = await storage.getUserByEmail(email);
    if (existingUser) {
      res.status(400).json({
        success: false,
        code: 400,
        message: 'Email already exists',
      });
      return;
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await storage.createUser({
      email,
      password: hashedPassword,
      name,
    });

    res.status(201).json(user.toResponse());
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

export async function deleteUser(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { id } = req.params;

    const user = await storage.getUserById(id);
    if (!user) {
      res.status(404).json({
        success: false,
        code: 404,
        message: 'User not found',
      });
      return;
    }

    await storage.deleteUser(id);

    res.status(204).send();
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}
