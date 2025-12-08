import { Router } from 'express';
import * as usersController from '../controllers/users';
import { authMiddleware } from '../middleware/auth';

const router = Router();

// GET /users/:id
router.get('/:id', authMiddleware, usersController.getUserById);

// GET /users
router.get('/', authMiddleware, usersController.getAllUsers);

// POST /users
router.post('/', authMiddleware, usersController.createUser);

// DELETE /users/:id
router.delete('/:id', authMiddleware, usersController.deleteUser);

export default router;
