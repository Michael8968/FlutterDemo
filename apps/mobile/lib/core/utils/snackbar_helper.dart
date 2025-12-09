import 'package:flutter/material.dart';

/// SnackBar 辅助类
/// 提供统一的消息提示方法
class SnackBarHelper {
  SnackBarHelper._();

  /// 显示成功消息
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// 显示错误消息
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  /// 显示警告消息
  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  /// 显示普通消息
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  /// 显示简单消息（无图标）
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 内部方法：显示带图标的 SnackBar
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
