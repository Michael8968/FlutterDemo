/// 文件工具类
/// 提供文件大小格式化等通用方法
class FileUtils {
  FileUtils._();

  /// 格式化文件大小
  /// 自动选择合适的单位 (B, KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 从路径获取文件名
  static String getFileName(String path) {
    return path.split('/').last;
  }

  /// 获取文件扩展名
  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }
}
