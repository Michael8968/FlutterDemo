import { Request, Response } from 'express';
import { authService } from '../services/auth';
import { AuthRequest } from '../middleware/auth';

export async function register(req: Request, res: Response): Promise<void> {
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

    const authResponse = await authService.register({ email, password, name });

    res.status(201).json({
      success: true,
      code: 201,
      data: authResponse,
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      code: 400,
      message: error.message,
    });
  }
}

export async function login(req: Request, res: Response): Promise<void> {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({
        success: false,
        code: 400,
        message: 'Email and password are required',
      });
      return;
    }

    const authResponse = await authService.login({ email, password });

    res.json({
      success: true,
      code: 200,
      data: authResponse,
    });
  } catch (error: any) {
    res.status(401).json({
      success: false,
      code: 401,
      message: error.message,
    });
  }
}

export async function refreshToken(req: Request, res: Response): Promise<void> {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      res.status(400).json({
        success: false,
        code: 400,
        message: 'Refresh token is required',
      });
      return;
    }

    const authResponse = await authService.refreshToken(refresh_token);

    res.json({
      success: true,
      code: 200,
      data: authResponse,
    });
  } catch (error: any) {
    res.status(401).json({
      success: false,
      code: 401,
      message: error.message,
    });
  }
}

export async function logout(req: AuthRequest, res: Response): Promise<void> {
  const { refresh_token } = req.body;
  await authService.logout(refresh_token);

  res.json({
    success: true,
    code: 200,
    message: 'Logged out successfully',
  });
}

export function verify(req: AuthRequest, res: Response): void {
  res.json({
    success: true,
    code: 200,
    message: 'Token is valid',
    data: {
      userId: req.userId,
      email: req.userEmail,
    },
  });
}
