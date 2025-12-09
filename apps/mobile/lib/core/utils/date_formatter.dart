/// 日期格式化工具类
/// 提供统一的日期和时间格式化方法
class DateFormatter {
  DateFormatter._();

  /// 格式化日期为 yyyy-MM-dd 格式
  /// 例如: 2024-01-15
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化日期为 yyyy/MM/dd 格式
  /// 例如: 2024/01/15
  static String formatDateSlash(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间为 yyyy/MM/dd HH:mm 格式
  /// 例如: 2024/01/15 14:30
  static String formatDateTime(DateTime dateTime) {
    return '${formatDateSlash(dateTime)} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间为简短格式 M/d HH:mm
  /// 例如: 1/15 14:30
  static String formatDateTimeShort(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化时间为 HH:mm 格式
  /// 例如: 14:30
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化为中文日期
  /// 例如: 1月15日
  static String formatDateChinese(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  /// 格式化为完整中文日期
  /// 例如: 2024年1月15日
  static String formatDateChineseFull(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 生成日期键值（用于Map索引）
  /// 例如: 2024-1-15
  static String dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
