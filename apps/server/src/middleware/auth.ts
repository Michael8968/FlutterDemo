import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth';
import { storage } from '../services/storage';

export interface AuthRequest extends Request {
  userId?: string;
  userEmail?: string;
}

export async function authMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({
      success: false,
      code: 401,
      message: 'Access token required',
    });
    return;
  }

  const token = authHeader.substring(7);

  try {
    const payload = authService.verifyAccessToken(token);

    const user = await storage.getUserById(payload.userId);
    if (!user) {
      res.status(401).json({
        success: false,
        code: 401,
        message: 'User not found',
      });
      return;
    }

    req.userId = payload.userId;
    req.userEmail = payload.email;
    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      code: 401,
      message: 'Invalid or expired token',
    });
  }
}
