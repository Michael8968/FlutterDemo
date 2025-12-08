import { Router } from 'express';
import * as authController from '../controllers/auth';
import { authMiddleware } from '../middleware/auth';

const router = Router();

// POST /auth/register
router.post('/register', authController.register);

// POST /auth/login
router.post('/login', authController.login);

// POST /auth/refresh
router.post('/refresh', authController.refreshToken);

// POST /auth/logout (requires auth)
router.post('/logout', authMiddleware, authController.logout);

// GET /auth/verify (requires auth)
router.get('/verify', authMiddleware, authController.verify);

export default router;
