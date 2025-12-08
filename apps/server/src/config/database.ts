import { DataSource } from 'typeorm';
import { User, Backup, SyncChange, RefreshToken } from '../entities';

// 检查必需的环境变量
const dbPassword = process.env.DB_PASSWORD;
if (dbPassword === undefined) {
  console.warn('警告: DB_PASSWORD 环境变量未设置，将使用空密码。如果 MySQL root 用户需要密码，请创建 .env 文件并设置 DB_PASSWORD。');
}

export const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  username: process.env.DB_USER || 'root',
  password: dbPassword !== undefined ? dbPassword : '',
  database: process.env.DB_NAME || 'flutter_demo',
  synchronize: process.env.NODE_ENV !== 'production', // 生产环境应关闭
  logging: process.env.NODE_ENV === 'development',
  entities: [User, Backup, SyncChange, RefreshToken],
  charset: 'utf8mb4',
});

export async function initializeDatabase(): Promise<void> {
  try {
    await AppDataSource.initialize();
    console.log('Database connection established');
  } catch (error: any) {
    console.error('Database connection failed:', error);
    
    // 提供更友好的错误提示
    if (error.code === 'ER_ACCESS_DENIED_ERROR') {
      console.error('\n数据库访问被拒绝。请检查以下配置：');
      console.error('1. 确保已创建 .env 文件（参考 .env.example）');
      console.error('2. 在 .env 文件中设置正确的 DB_PASSWORD');
      console.error('3. 确认 MySQL root 用户的密码是否正确');
      console.error('4. 确认 MySQL 服务正在运行');
    }
    
    throw error;
  }
}
