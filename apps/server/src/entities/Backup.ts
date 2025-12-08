import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './User';

@Entity('backups')
export class Backup {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'file_name' })
  fileName: string;

  @Column({ name: 'file_size' })
  fileSize: number;

  @Column({ name: 'device_info', nullable: true })
  deviceInfo: string;

  @Column({ nullable: true })
  version: string;

  @Column({ type: 'json' })
  data: Record<string, any>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User, (user) => user.backups)
  @JoinColumn({ name: 'user_id' })
  user: User;

  toResponse() {
    return {
      id: this.id,
      file_name: this.fileName,
      file_size: this.fileSize,
      device_info: this.deviceInfo,
      version: this.version,
      created_at: this.createdAt,
    };
  }

  toDataResponse() {
    return {
      diaries: this.data.diaries || [],
      symptoms: this.data.symptoms || [],
      profile: this.data.profile,
      settings: this.data.settings,
      version: this.version,
      created_at: this.createdAt,
    };
  }
}
