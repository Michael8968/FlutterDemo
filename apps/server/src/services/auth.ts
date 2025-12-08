import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { config } from '../config';
import { storage } from './storage';
import { User } from '../entities';
import { AuthResponse, TokenPayload, RegisterRequest, LoginRequest } from '../models/auth';

class AuthService {
  async register(request: RegisterRequest): Promise<AuthResponse> {
    const existingUser = await storage.getUserByEmail(request.email);
    if (existingUser) {
      throw new Error('Email already registered');
    }

    const hashedPassword = await bcrypt.hash(request.password, 10);

    const user = await storage.createUser({
      email: request.email,
      password: hashedPassword,
      name: request.name,
    });

    return await this.generateAuthResponse(user);
  }

  async login(request: LoginRequest): Promise<AuthResponse> {
    const user = await storage.getUserByEmail(request.email);
    if (!user) {
      throw new Error('Invalid email or password');
    }

    const isValidPassword = await bcrypt.compare(request.password, user.password);
    if (!isValidPassword) {
      throw new Error('Invalid email or password');
    }

    return await this.generateAuthResponse(user);
  }

  async refreshToken(refreshToken: string): Promise<AuthResponse> {
    const tokenRecord = await storage.findRefreshToken(refreshToken);
    if (!tokenRecord) {
      throw new Error('Invalid refresh token');
    }

    if (tokenRecord.expiresAt < new Date()) {
      await storage.removeRefreshToken(refreshToken);
      throw new Error('Refresh token expired');
    }

    try {
      const payload = jwt.verify(refreshToken, config.jwtSecret) as TokenPayload;

      if (payload.type !== 'refresh') {
        throw new Error('Invalid token type');
      }

      const user = await storage.getUserById(payload.userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Remove old refresh token
      await storage.removeRefreshToken(refreshToken);

      return await this.generateAuthResponse(user);
    } catch (error) {
      await storage.removeRefreshToken(refreshToken);
      throw new Error('Invalid refresh token');
    }
  }

  async logout(refreshToken?: string): Promise<void> {
    if (refreshToken) {
      await storage.removeRefreshToken(refreshToken);
    }
  }

  verifyAccessToken(token: string): TokenPayload {
    const payload = jwt.verify(token, config.jwtSecret) as TokenPayload;

    if (payload.type !== 'access') {
      throw new Error('Invalid token type');
    }

    return payload;
  }

  private async generateAuthResponse(user: User): Promise<AuthResponse> {
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    // Calculate expiration date for refresh token (30 days)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await storage.addRefreshToken(user.id, refreshToken, expiresAt);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: 7 * 24 * 60 * 60, // 7 days in seconds
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    };
  }

  private generateAccessToken(user: User): string {
    const payload: TokenPayload = {
      userId: user.id,
      email: user.email,
      type: 'access',
    };

    return jwt.sign(payload, config.jwtSecret, {
      expiresIn: config.jwtExpiresIn as jwt.SignOptions['expiresIn'],
    });
  }

  private generateRefreshToken(user: User): string {
    const payload: TokenPayload = {
      userId: user.id,
      email: user.email,
      type: 'refresh',
    };

    return jwt.sign(payload, config.jwtSecret, {
      expiresIn: config.jwtRefreshExpiresIn as jwt.SignOptions['expiresIn'],
    });
  }
}

export const authService = new AuthService();
