import 'reflect-metadata';
import dotenv from 'dotenv';

// Load environment variables BEFORE importing config
dotenv.config();

import express from 'express';
import cors from 'cors';
import { config, initializeDatabase } from './config';
import authRoutes from './routes/auth';
import usersRoutes from './routes/users';
import syncRoutes from './routes/sync';

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'Server is running' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', usersRoutes);
app.use('/api/v1/sync', syncRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    code: 404,
    message: 'Not found',
  });
});

// Error handler
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    code: 500,
    message: 'Internal server error',
  });
});

// Initialize database and start server
async function bootstrap() {
  try {
    await initializeDatabase();

    app.listen(config.port, () => {
      console.log(`Server is running on http://localhost:${config.port}`);
      console.log('Available routes:');
      console.log('  POST   /api/v1/auth/register');
      console.log('  POST   /api/v1/auth/login');
      console.log('  POST   /api/v1/auth/refresh');
      console.log('  POST   /api/v1/auth/logout');
      console.log('  GET    /api/v1/auth/verify');
      console.log('  GET    /api/v1/users');
      console.log('  GET    /api/v1/users/:id');
      console.log('  POST   /api/v1/users');
      console.log('  DELETE /api/v1/users/:id');
      console.log('  POST   /api/v1/sync/backup');
      console.log('  GET    /api/v1/sync/backup/:id');
      console.log('  GET    /api/v1/sync/backups');
      console.log('  DELETE /api/v1/sync/backup/:id');
      console.log('  POST   /api/v1/sync/incremental');
      console.log('  GET    /api/v1/sync/changes');
      console.log('  GET    /api/v1/sync/status');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

bootstrap();
