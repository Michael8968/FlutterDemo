import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../health_diary/presentation/bloc/diary_bloc.dart';
import '../../../health_diary/presentation/bloc/diary_event.dart';
import '../../../health_diary/presentation/bloc/diary_state.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import '../../../symptom_tracker/presentation/bloc/symptom_bloc.dart';
import '../../../symptom_tracker/presentation/bloc/symptom_event.dart';
import '../../../symptom_tracker/presentation/bloc/symptom_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/services/export_service.dart';

/// 数据导出页面
class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final ExportService _exportService = ExportService();

  ExportDataType _selectedDataType = ExportDataType.all;
  ExportFormat _selectedFormat = ExportFormat.json;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  List<DiaryEntry> _diaries = [];
  List<SymptomEntry> _symptoms = [];
  bool _isExporting = false;
  List<FileSystemEntity> _exportedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadExportedFiles();
  }

  void _loadData() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));

    context.read<DiaryBloc>().add(LoadDiaryRange(startDate, now));
    context.read<SymptomBloc>().add(LoadSymptomsByDateRange(startDate, now));
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  Future<void> _loadExportedFiles() async {
    final files = await _exportService.getExportedFiles();
    setState(() => _exportedFiles = files);
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);

    ExportResult result;

    switch (_selectedDataType) {
      case ExportDataType.diary:
        result = await _exportService.exportDiaries(
          diaries: _diaries,
          format: _selectedFormat,
          startDate: _startDate,
          endDate: _endDate,
        );
        break;
      case ExportDataType.symptom:
        result = await _exportService.exportSymptoms(
          symptoms: _symptoms,
          format: _selectedFormat,
          startDate: _startDate,
          endDate: _endDate,
        );
        break;
      case ExportDataType.all:
        final profileState = context.read<ProfileBloc>().state;
        final profile = profileState is ProfileLoaded ? profileState.profile : null;

        result = await _exportService.exportAll(
          diaries: _diaries,
          symptoms: _symptoms,
          profile: profile,
          format: _selectedFormat,
          startDate: _startDate,
          endDate: _endDate,
        );
        break;
    }

    setState(() => _isExporting = false);

    if (result.success && result.filePath != null) {
      await _loadExportedFiles();
      if (mounted) {
        _showExportSuccessDialog(result);
      }
    } else {
      if (mounted) {
        SnackBarHelper.showError(context, result.error ?? '导出失败');
      }
    }
  }

  void _showExportSuccessDialog(ExportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('导出成功'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('已导出 ${result.recordCount} 条记录'),
            const SizedBox(height: 8),
            Text(
              '文件路径: ${result.filePath}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareFile(result.filePath!);
            },
            icon: const Icon(Icons.share),
            label: const Text('分享'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '分享失败: $e');
      }
    }
  }

  Future<void> _deleteFile(String filePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除此导出文件吗？'),
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
      final success = await _exportService.deleteExportedFile(filePath);
      if (success) {
        await _loadExportedFiles();
        if (mounted) {
          SnackBarHelper.show(context, '文件已删除');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导出'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DiaryBloc, DiaryState>(
            listener: (context, state) {
              if (state is DiaryRangeLoaded) {
                setState(() => _diaries = state.entries);
              } else if (state is DiaryListLoaded) {
                setState(() => _diaries = state.entries);
              }
            },
          ),
          BlocListener<SymptomBloc, SymptomState>(
            listener: (context, state) {
              if (state is SymptomLoaded) {
                setState(() => _symptoms = state.symptoms);
              }
            },
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 导出设置卡片
            _buildExportSettingsCard(),
            const SizedBox(height: 16),

            // 数据预览
            _buildDataPreviewCard(),
            const SizedBox(height: 16),

            // 导出按钮
            _buildExportButton(),
            const SizedBox(height: 24),

            // 已导出文件列表
            _buildExportedFilesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, size: 20),
                SizedBox(width: 8),
                Text(
                  '导出设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 数据类型选择
            const Text('选择数据类型'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ExportDataType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: _selectedDataType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDataType = type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 格式选择
            const Text('选择导出格式'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ExportFormat.values.map((format) {
                return ChoiceChip(
                  label: Text(format.displayName),
                  selected: _selectedFormat == format,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFormat = format);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 日期范围选择
            const Text('选择日期范围'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: '开始日期',
                    date: _startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('至'),
                ),
                Expanded(
                  child: _buildDateSelector(
                    label: '结束日期',
                    date: _endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(DateFormatter.formatDate(date)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Widget _buildDataPreviewCard() {
    int recordCount;
    String description;

    switch (_selectedDataType) {
      case ExportDataType.diary:
        recordCount = _diaries
            .where((d) =>
                d.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                d.date.isBefore(_endDate.add(const Duration(days: 1))))
            .length;
        description = '健康日记记录';
        break;
      case ExportDataType.symptom:
        recordCount = _symptoms
            .where((s) =>
                s.timestamp.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                s.timestamp.isBefore(_endDate.add(const Duration(days: 1))))
            .length;
        description = '症状记录';
        break;
      case ExportDataType.all:
        final diaryCount = _diaries
            .where((d) =>
                d.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                d.date.isBefore(_endDate.add(const Duration(days: 1))))
            .length;
        final symptomCount = _symptoms
            .where((s) =>
                s.timestamp.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                s.timestamp.isBefore(_endDate.add(const Duration(days: 1))))
            .length;
        recordCount = diaryCount + symptomCount;
        description = '日记 $diaryCount 条 + 症状 $symptomCount 条';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$recordCount 条记录',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : _export,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.download),
        label: Text(_isExporting ? '正在导出...' : '导出数据'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildExportedFilesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '已导出文件',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_exportedFiles.length} 个文件',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (_exportedFiles.isEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_off,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无导出文件',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 12),
              ..._exportedFiles.take(10).map((file) => _buildFileItem(file)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(FileSystemEntity file) {
    final fileName = FileUtils.getFileName(file.path);
    final stat = file.statSync();
    final fileSize = FileUtils.formatFileSize(stat.size);
    final modifiedDate = DateFormatter.formatDateTimeShort(stat.modified);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getFileColor(fileName).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getFileIcon(fileName),
          color: _getFileColor(fileName),
        ),
      ),
      title: Text(
        fileName,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$fileSize · $modifiedDate',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            onPressed: () => _shareFile(file.path),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () => _deleteFile(file.path),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.csv')) return Icons.table_chart;
    if (fileName.endsWith('.json')) return Icons.data_object;
    return Icons.description;
  }

  Color _getFileColor(String fileName) {
    if (fileName.endsWith('.csv')) return Colors.green;
    if (fileName.endsWith('.json')) return Colors.orange;
    return Colors.blue;
  }
}
