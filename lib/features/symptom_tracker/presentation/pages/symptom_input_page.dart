import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/symptom_category.dart';
import '../../domain/entities/body_part.dart';
import '../bloc/symptom_bloc.dart';
import '../bloc/symptom_event.dart';
import '../bloc/symptom_state.dart';
import '../widgets/severity_slider.dart';
import '../widgets/symptom_chip.dart';

/// 症状输入页面
class SymptomInputPage extends StatefulWidget {
  const SymptomInputPage({super.key});

  @override
  State<SymptomInputPage> createState() => _SymptomInputPageState();
}

class _SymptomInputPageState extends State<SymptomInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _symptomNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _customTriggerController = TextEditingController();

  SymptomType _selectedType = SymptomType.pain;
  SymptomTemplate? _selectedTemplate;
  int _severity = 5;
  final List<String> _selectedBodyParts = [];
  final List<String> _selectedTriggers = [];
  bool _isOngoing = false;

  @override
  void dispose() {
    _symptomNameController.dispose();
    _notesController.dispose();
    _customTriggerController.dispose();
    super.dispose();
  }

  void _selectTemplate(SymptomTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _symptomNameController.text = template.name;
      _selectedType = template.type;
    });
  }

  void _toggleBodyPart(String part) {
    setState(() {
      if (_selectedBodyParts.contains(part)) {
        _selectedBodyParts.remove(part);
      } else {
        _selectedBodyParts.add(part);
      }
    });
  }

  void _toggleTrigger(String trigger) {
    setState(() {
      if (_selectedTriggers.contains(trigger)) {
        _selectedTriggers.remove(trigger);
      } else {
        _selectedTriggers.add(trigger);
      }
    });
  }

  void _addCustomTrigger() {
    final trigger = _customTriggerController.text.trim();
    if (trigger.isNotEmpty && !_selectedTriggers.contains(trigger)) {
      setState(() {
        _selectedTriggers.add(trigger);
        _customTriggerController.clear();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SymptomBloc>().add(AddSymptomEvent(
            symptomName: _symptomNameController.text.trim(),
            templateId: _selectedTemplate?.id,
            type: _selectedType,
            severity: _severity,
            bodyParts: _selectedBodyParts,
            triggers: _selectedTriggers,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            isOngoing: _isOngoing,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SymptomBloc, SymptomState>(
      listener: (context, state) {
        if (state is SymptomOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is SymptomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('记录症状'),
          actions: [
            TextButton(
              onPressed: _submit,
              child: const Text('保存'),
            ),
          ],
        ),
        body: BlocBuilder<SymptomBloc, SymptomState>(
          builder: (context, state) {
            if (state is SymptomLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 症状类型选择
                  Text(
                    '症状类型',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SymptomTypeSelector(
                    selectedType: _selectedType,
                    onSelected: (type) {
                      setState(() {
                        _selectedType = type;
                        _selectedTemplate = null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // 常见症状快速选择
                  Text(
                    '快速选择',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SymptomTemplates.getByType(_selectedType)
                        .map((template) => SymptomChip(
                              template: template,
                              isSelected: _selectedTemplate == template,
                              onTap: () => _selectTemplate(template),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // 症状名称输入
                  TextFormField(
                    controller: _symptomNameController,
                    decoration: const InputDecoration(
                      labelText: '症状名称',
                      hintText: '输入或从上方选择',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入症状名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 严重程度
                  SeveritySlider(
                    value: _severity,
                    onChanged: (v) => setState(() => _severity = v),
                  ),
                  const SizedBox(height: 24),

                  // 身体部位选择
                  Text(
                    '涉及部位',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...BodyRegion.values.map((region) => ExpansionTile(
                        title: Text(region.displayName),
                        initiallyExpanded: _selectedBodyParts.any(
                          (p) => BodyPart.values
                              .where((bp) => bp.name == p)
                              .any((bp) => bp.region == region),
                        ),
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: BodyPart.getByRegion(region)
                                .map((part) => FilterChip(
                                      label: Text(part.displayName),
                                      selected:
                                          _selectedBodyParts.contains(part.name),
                                      onSelected: (_) =>
                                          _toggleBodyPart(part.name),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      )),
                  const SizedBox(height: 16),

                  // 可能诱因
                  Text(
                    '可能诱因',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_selectedTemplate != null &&
                      _selectedTemplate!.commonTriggers.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTemplate!.commonTriggers
                          .map((trigger) => FilterChip(
                                label: Text(trigger),
                                selected: _selectedTriggers.contains(trigger),
                                onSelected: (_) => _toggleTrigger(trigger),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customTriggerController,
                          decoration: const InputDecoration(
                            hintText: '添加其他诱因',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _addCustomTrigger(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addCustomTrigger,
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  if (_selectedTriggers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTriggers
                          .map((trigger) => Chip(
                                label: Text(trigger),
                                onDeleted: () => _toggleTrigger(trigger),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 是否正在发作
                  SwitchListTile(
                    title: const Text('症状正在发作中'),
                    subtitle: const Text('开启后可稍后标记结束时间'),
                    value: _isOngoing,
                    onChanged: (v) => setState(() => _isOngoing = v),
                  ),
                  const SizedBox(height: 16),

                  // 备注
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: '备注（可选）',
                      hintText: '添加更多描述...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // 提交按钮
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '保存记录',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
