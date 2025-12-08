import { MoreThan, Repository } from 'typeorm';
import { AppDataSource } from '../config/database';
import { User, Backup, SyncChange, RefreshToken, DataType, ActionType } from '../entities';

class StorageService {
  private get userRepo(): Repository<User> {
    return AppDataSource.getRepository(User);
  }

  private get backupRepo(): Repository<Backup> {
    return AppDataSource.getRepository(Backup);
  }

  private get syncChangeRepo(): Repository<SyncChange> {
    return AppDataSource.getRepository(SyncChange);
  }

  private get refreshTokenRepo(): Repository<RefreshToken> {
    return AppDataSource.getRepository(RefreshToken);
  }

  // User operations
  async createUser(userData: Partial<User>): Promise<User> {
    const user = this.userRepo.create(userData);
    return await this.userRepo.save(user);
  }

  async getUserById(id: string): Promise<User | null> {
    return await this.userRepo.findOne({ where: { id } });
  }

  async getUserByEmail(email: string): Promise<User | null> {
    return await this.userRepo.findOne({ where: { email } });
  }

  async getAllUsers(): Promise<User[]> {
    return await this.userRepo.find();
  }

  async updateUser(id: string, updates: Partial<User>): Promise<User | null> {
    await this.userRepo.update(id, updates);
    return await this.getUserById(id);
  }

  async deleteUser(id: string): Promise<boolean> {
    const result = await this.userRepo.delete(id);
    return (result.affected || 0) > 0;
  }

  // Backup operations
  async createBackup(backupData: Partial<Backup>): Promise<Backup> {
    const backup = this.backupRepo.create(backupData);
    return await this.backupRepo.save(backup);
  }

  async getBackupById(id: string): Promise<Backup | null> {
    return await this.backupRepo.findOne({ where: { id } });
  }

  async getBackupsByUserId(userId: string): Promise<Backup[]> {
    return await this.backupRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async deleteBackup(id: string): Promise<boolean> {
    const result = await this.backupRepo.delete(id);
    return (result.affected || 0) > 0;
  }

  // Sync change operations
  async addSyncChange(
    userId: string,
    dataType: DataType,
    action: ActionType,
    data: Record<string, any>
  ): Promise<SyncChange> {
    const change = this.syncChangeRepo.create({
      userId,
      dataType,
      action,
      data,
    });
    return await this.syncChangeRepo.save(change);
  }

  async getSyncChangesSince(userId: string, since: Date): Promise<SyncChange[]> {
    return await this.syncChangeRepo.find({
      where: {
        userId,
        timestamp: MoreThan(since),
      },
      order: { timestamp: 'ASC' },
    });
  }

  // Refresh token operations
  async addRefreshToken(userId: string, token: string, expiresAt: Date): Promise<RefreshToken> {
    const refreshToken = this.refreshTokenRepo.create({
      userId,
      token,
      expiresAt,
    });
    return await this.refreshTokenRepo.save(refreshToken);
  }

  async findRefreshToken(token: string): Promise<RefreshToken | null> {
    return await this.refreshTokenRepo.findOne({ where: { token } });
  }

  async removeRefreshToken(token: string): Promise<void> {
    await this.refreshTokenRepo.delete({ token });
  }

  async removeExpiredTokens(): Promise<void> {
    await this.refreshTokenRepo
      .createQueryBuilder()
      .delete()
      .where('expires_at < :now', { now: new Date() })
      .execute();
  }
}

export const storage = new StorageService();
