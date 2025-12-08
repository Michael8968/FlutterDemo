export interface Backup {
  id: string;
  userId: string;
  fileName: string;
  fileSize: number;
  deviceInfo?: string;
  version?: string;
  data: BackupData;
  createdAt: Date;
}

export interface BackupData {
  diaries?: Record<string, any>[];
  symptoms?: Record<string, any>[];
  profile?: Record<string, any>;
  settings?: Record<string, any>;
  version?: string;
  createdAt?: Date;
}

export interface BackupResponse {
  id: string;
  file_name: string;
  file_size: number;
  device_info?: string;
  version?: string;
  created_at: Date;
}

export interface SyncChange {
  id: string;
  userId: string;
  dataType: 'diary' | 'symptom' | 'profile' | 'achievement' | 'reminder' | 'settings';
  action: 'create' | 'update' | 'delete';
  data: Record<string, any>;
  timestamp: Date;
}

export interface IncrementalSyncRequest {
  last_sync_time?: string;
  local_changes: {
    diaries: Record<string, any>[];
    symptoms: Record<string, any>[];
    profile?: Record<string, any>;
    deleted_ids: string[];
  };
  device_id: string;
}

export interface SyncChangesResponse {
  diaries: Record<string, any>[];
  symptoms: Record<string, any>[];
  profile?: Record<string, any>;
  achievements: Record<string, any>[];
  reminders: Record<string, any>[];
  settings?: Record<string, any>;
  server_time: Date;
  has_more: boolean;
}

export interface SyncResultResponse {
  success: boolean;
  synced_count: number;
  conflict_count: number;
  conflicts: SyncConflict[];
  server_time: Date;
}

export interface SyncConflict {
  id: string;
  data_type: string;
  local_data: Record<string, any>;
  server_data: Record<string, any>;
  local_modified_at: Date;
  server_modified_at: Date;
}

export interface SyncStatusResponse {
  last_sync_time?: Date;
  pending_changes: number;
  is_syncing: boolean;
  server_time: Date;
}
