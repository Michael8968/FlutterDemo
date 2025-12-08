import { Router } from 'express';
import * as syncController from '../controllers/sync';
import { authMiddleware } from '../middleware/auth';

const router = Router();

// All sync routes require authentication
router.use(authMiddleware);

// POST /sync/backup - 上传完整备份
router.post('/backup', syncController.uploadBackup);

// GET /sync/backup/:id - 下载备份
router.get('/backup/:id', syncController.downloadBackup);

// GET /sync/backups - 获取备份列表
router.get('/backups', syncController.getBackups);

// DELETE /sync/backup/:id - 删除备份
router.delete('/backup/:id', syncController.deleteBackup);

// POST /sync/incremental - 增量同步
router.post('/incremental', syncController.syncIncremental);

// GET /sync/changes - 获取服务器变更
router.get('/changes', syncController.getChanges);

// GET /sync/status - 获取同步状态
router.get('/status', syncController.getSyncStatus);

export default router;
