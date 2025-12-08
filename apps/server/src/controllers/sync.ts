import { Response } from 'express';
import { storage } from '../services/storage';
import { AuthRequest } from '../middleware/auth';
import {
  IncrementalSyncRequest,
  SyncChangesResponse,
  SyncResultResponse,
  SyncStatusResponse,
} from '../models/backup';

// POST /sync/backup - 上传完整备份
export async function uploadBackup(req: AuthRequest, res: Response): Promise<void> {
  try {
    const userId = req.userId!;
    const backupData = req.body;

    const now = new Date();
    const backup = await storage.createBackup({
      userId,
      fileName: `backup_${now.toISOString()}.json`,
      fileSize: JSON.stringify(backupData).length,
      deviceInfo: req.headers['x-device-info'] as string,
      version: backupData.version || '1.0.0',
      data: backupData,
    });

    res.status(201).json(backup.toResponse());
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

// GET /sync/backup/:id - 下载备份
export async function downloadBackup(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const userId = req.userId!;

    const backup = await storage.getBackupById(id);

    if (!backup) {
      res.status(404).json({
        success: false,
        code: 404,
        message: 'Backup not found',
      });
      return;
    }

    if (backup.userId !== userId) {
      res.status(403).json({
        success: false,
        code: 403,
        message: 'Access denied',
      });
      return;
    }

    res.json(backup.toDataResponse());
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

// GET /sync/backups - 获取备份列表
export async function getBackups(req: AuthRequest, res: Response): Promise<void> {
  try {
    const userId = req.userId!;
    const backups = await storage.getBackupsByUserId(userId);

    res.json(backups.map(backup => backup.toResponse()));
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

// DELETE /sync/backup/:id - 删除备份
export async function deleteBackup(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const userId = req.userId!;

    const backup = await storage.getBackupById(id);

    if (!backup) {
      res.status(404).json({
        success: false,
        code: 404,
        message: 'Backup not found',
      });
      return;
    }

    if (backup.userId !== userId) {
      res.status(403).json({
        success: false,
        code: 403,
        message: 'Access denied',
      });
      return;
    }

    await storage.deleteBackup(id);
    res.status(204).send();
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

// POST /sync/incremental - 增量同步
export async function syncIncremental(req: AuthRequest, res: Response): Promise<void> {
  try {
    const userId = req.userId!;
    const syncRequest: IncrementalSyncRequest = req.body;
    const now = new Date();

    let syncedCount = 0;
    const conflicts: any[] = [];

    // 处理本地变更
    const { local_changes } = syncRequest;

    // 处理日记变更
    for (const diary of local_changes.diaries || []) {
      await storage.addSyncChange(userId, 'diary', 'update', diary);
      syncedCount++;
    }

    // 处理症状变更
    for (const symptom of local_changes.symptoms || []) {
      await storage.addSyncChange(userId, 'symptom', 'update', symptom);
      syncedCount++;
    }

    // 处理个人资料变更
    if (local_changes.profile) {
      await storage.addSyncChange(userId, 'profile', 'update', local_changes.profile);
      syncedCount++;
    }

    // 处理删除
    for (const deletedId of local_changes.deleted_ids || []) {
      await storage.addSyncChange(userId, 'diary', 'delete', { id: deletedId });
      syncedCount++;
    }

    const response: SyncResultResponse = {
      success: true,
      synced_count: syncedCount,
      conflict_count: conflicts.length,
      conflicts,
      server_time: now,
    };

    res.json(response);
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

// GET /sync/changes - 获取服务器变更
export async function getChanges(req: AuthRequest, res: Response): Promise<void> {
  try {
    const userId = req.userId!;
    const since = req.query.since as string;
    const limit = parseInt(req.query.limit as string) || 100;

    const sinceDate = since ? new Date(since) : new Date(0);
    const changes = await storage.getSyncChangesSince(userId, sinceDate);

    // 按类型分组变更
    const diaries: Record<string, any>[] = [];
    const symptoms: Record<string, any>[] = [];
    let profile: Record<string, any> | undefined;
    const achievements: Record<string, any>[] = [];
    const reminders: Record<string, any>[] = [];
    let settings: Record<string, any> | undefined;

    for (const change of changes.slice(0, limit)) {
      switch (change.dataType) {
        case 'diary':
          diaries.push(change.data);
          break;
        case 'symptom':
          symptoms.push(change.data);
          break;
        case 'profile':
          profile = change.data;
          break;
        case 'achievement':
          achievements.push(change.data);
          break;
        case 'reminder':
          reminders.push(change.data);
          break;
        case 'settings':
          settings = change.data;
          break;
      }
    }

    const response: SyncChangesResponse = {
      diaries,
      symptoms,
      profile,
      achievements,
      reminders,
      settings,
      server_time: new Date(),
      has_more: changes.length > limit,
    };

    res.json(response);
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}

// GET /sync/status - 获取同步状态
export async function getSyncStatus(req: AuthRequest, res: Response): Promise<void> {
  try {
    const userId = req.userId!;
    const changes = await storage.getSyncChangesSince(userId, new Date(0));

    const response: SyncStatusResponse = {
      last_sync_time: changes.length > 0 ? changes[changes.length - 1].timestamp : undefined,
      pending_changes: 0,
      is_syncing: false,
      server_time: new Date(),
    };

    res.json(response);
  } catch (error: any) {
    res.status(500).json({
      success: false,
      code: 500,
      message: error.message,
    });
  }
}
