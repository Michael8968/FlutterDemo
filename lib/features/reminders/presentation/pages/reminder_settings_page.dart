import 'package:flutter/material.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/services/notification_service.dart';

/// 提醒设置页面
class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  final ReminderRepository _repository = ReminderRepository();
  final NotificationService _notificationService = NotificationService();

  List<Reminder> _reminders = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initialize();
    _hasPermission = await _notificationService.requestPermission();
    await _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final reminders = await _repository.getAllReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  Future<void> _addReminder({ReminderType? type}) async {
    final result = await showModalBottomSheet<Reminder>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddReminderSheet(
        preselectedType: type,
      ),
    );

    if (result != null) {
      await _repository.saveReminder(result);
      await _loadReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提醒已添加')),
        );
      }
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    final result = await showModalBottomSheet<Reminder>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddReminderSheet(
        existingReminder: reminder,
      ),
    );

    if (result != null) {
      await _repository.saveReminder(result);
      await _loadReminders();
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除提醒'),
        content: Text('确定要删除"${reminder.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteReminder(reminder.id);
      await _loadReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提醒已删除')),
        );
      }
    }
  }

  Future<void> _toggleReminder(Reminder reminder, bool isEnabled) async {
    await _repository.toggleReminder(reminder.id, isEnabled);
    await _loadReminders();
  }

  Future<void> _testReminder(Reminder reminder) async {
    await _notificationService.showTestNotification(reminder);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('测试通知已发送')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addReminder(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 快捷添加
        _buildQuickAddSection(),
        const SizedBox(height: 24),

        // 提醒列表
        _buildRemindersSection(),
      ],
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              '需要通知权限',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请允许通知权限以接收健康提醒',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                _hasPermission = await _notificationService.requestPermission();
                setState(() {});
              },
              child: const Text('授予权限'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flash_on, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  '快速添加',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderType.values
                  .where((t) => t != ReminderType.custom)
                  .map((type) => _buildQuickAddChip(type))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddChip(ReminderType type) {
    return ActionChip(
      avatar: Icon(_getTypeIcon(type), size: 18),
      label: Text(type.displayName),
      onPressed: () => _addReminder(type: type),
    );
  }

  Widget _buildRemindersSection() {
    if (_reminders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.notifications_none,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              const Text(
                '暂无提醒',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '点击上方按钮添加健康提醒',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    // 按类型分组显示
    final groupedReminders = <ReminderType, List<Reminder>>{};
    for (final reminder in _reminders) {
      groupedReminders.putIfAbsent(reminder.type, () => []);
      groupedReminders[reminder.type]!.add(reminder);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '我的提醒',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_reminders.length} 个提醒',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...groupedReminders.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(entry.key),
                      size: 18,
                      color: _getTypeColor(entry.key),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((reminder) => _buildReminderCard(reminder)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: reminder.isEnabled
                ? _getTypeColor(reminder.type).withOpacity(0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              reminder.timeString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: reminder.isEnabled
                    ? _getTypeColor(reminder.type)
                    : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            color: reminder.isEnabled ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          reminder.repeatDescription,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_active, size: 20),
              onPressed: () => _testReminder(reminder),
              tooltip: '测试通知',
            ),
            Switch(
              value: reminder.isEnabled,
              onChanged: (value) => _toggleReminder(reminder, value),
            ),
          ],
        ),
        onTap: () => _editReminder(reminder),
        onLongPress: () => _deleteReminder(reminder),
      ),
    );
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.medicine:
        return Icons.medication;
      case ReminderType.exercise:
        return Icons.fitness_center;
      case ReminderType.sleep:
        return Icons.bedtime;
      case ReminderType.diary:
        return Icons.book;
      case ReminderType.meal:
        return Icons.restaurant;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Colors.blue;
      case ReminderType.medicine:
        return Colors.red;
      case ReminderType.exercise:
        return Colors.orange;
      case ReminderType.sleep:
        return Colors.indigo;
      case ReminderType.diary:
        return Colors.teal;
      case ReminderType.meal:
        return Colors.green;
      case ReminderType.custom:
        return Colors.purple;
    }
  }
}

/// 添加/编辑提醒底部表单
class _AddReminderSheet extends StatefulWidget {
  final ReminderType? preselectedType;
  final Reminder? existingReminder;

  const _AddReminderSheet({
    this.preselectedType,
    this.existingReminder,
  });

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  late ReminderType _type;
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TimeOfDay _time;
  late RepeatType _repeatType;
  late Set<int> _customDays;

  @override
  void initState() {
    super.initState();

    if (widget.existingReminder != null) {
      final r = widget.existingReminder!;
      _type = r.type;
      _titleController = TextEditingController(text: r.title);
      _messageController = TextEditingController(text: r.message);
      _time = TimeOfDay(hour: r.hour, minute: r.minute);
      _repeatType = r.repeatType;
      _customDays = r.customDays.toSet();
    } else {
      _type = widget.preselectedType ?? ReminderType.water;
      _titleController = TextEditingController(text: _type.displayName);
      _messageController = TextEditingController(text: _type.defaultMessage);
      _time = const TimeOfDay(hour: 9, minute: 0);
      _repeatType = RepeatType.daily;
      _customDays = {};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入提醒标题')),
      );
      return;
    }

    final reminder = Reminder(
      id: widget.existingReminder?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      title: _titleController.text,
      message: _messageController.text,
      hour: _time.hour,
      minute: _time.minute,
      repeatType: _repeatType,
      customDays: _customDays.toList()..sort(),
      isEnabled: widget.existingReminder?.isEnabled ?? true,
      createdAt: widget.existingReminder?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, reminder);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existingReminder != null ? '编辑提醒' : '添加提醒',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 提醒类型
            const Text('提醒类型', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderType.values.map((type) {
                final isSelected = _type == type;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _type = type;
                        if (_titleController.text == _type.displayName ||
                            _titleController.text.isEmpty) {
                          _titleController.text = type.displayName;
                        }
                        if (_messageController.text.isEmpty ||
                            _messageController.text == _type.defaultMessage) {
                          _messageController.text = type.defaultMessage;
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 提醒时间
            const Text('提醒时间', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) {
                  setState(() => _time = picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Text(
                      _time.format(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 重复设置
            const Text('重复', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RepeatType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: _repeatType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _repeatType = type);
                    }
                  },
                );
              }).toList(),
            ),

            // 自定义日期选择
            if (_repeatType == RepeatType.custom) ...[
              const SizedBox(height: 12),
              _buildDaySelector(),
            ],
            const SizedBox(height: 20),

            // 标题
            const Text('标题', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '提醒标题',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 消息
            const Text('消息内容', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '提醒消息内容',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.existingReminder != null ? '保存修改' : '添加提醒',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['日', '一', '二', '三', '四', '五', '六'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isSelected = _customDays.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _customDays.remove(index);
              } else {
                _customDays.add(index);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
