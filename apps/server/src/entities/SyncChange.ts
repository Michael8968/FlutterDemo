import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from './User';

export type DataType = 'diary' | 'symptom' | 'profile' | 'achievement' | 'reminder' | 'settings';
export type ActionType = 'create' | 'update' | 'delete';

@Entity('sync_changes')
@Index(['userId', 'timestamp'])
export class SyncChange {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'data_type' })
  dataType: DataType;

  @Column()
  action: ActionType;

  @Column({ type: 'json' })
  data: Record<string, any>;

  @CreateDateColumn({ name: 'timestamp' })
  timestamp: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
