import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// 编辑档案页面
class EditProfilePage extends StatefulWidget {
  final UserProfile? profile;

  const EditProfilePage({super.key, this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;

  Gender? _selectedGender;
  DateTime? _selectedBirthday;
  BloodType? _selectedBloodType;

  final List<String> _allergies = [];
  final List<String> _chronicDiseases = [];
  final List<String> _medications = [];

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nicknameController = TextEditingController(text: profile?.nickname ?? '');
    _heightController = TextEditingController(
      text: profile?.height?.toStringAsFixed(0) ?? '',
    );
    _weightController = TextEditingController(
      text: profile?.weight?.toStringAsFixed(1) ?? '',
    );
    _emergencyContactController = TextEditingController(
      text: profile?.emergencyContact ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: profile?.emergencyPhone ?? '',
    );
    _selectedGender = profile?.gender;
    _selectedBirthday = profile?.birthday;
    _selectedBloodType = profile?.bloodType;
    _allergies.addAll(profile?.allergies ?? []);
    _chronicDiseases.addAll(profile?.chronicDiseases ?? []);
    _medications.addAll(profile?.medications ?? []);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final existingProfile = widget.profile;

    final profile = UserProfile(
      id: existingProfile?.id ?? '${now.millisecondsSinceEpoch}',
      nickname: _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      gender: _selectedGender,
      birthday: _selectedBirthday,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      bloodType: _selectedBloodType,
      allergies: _allergies,
      chronicDiseases: _chronicDiseases,
      medications: _medications,
      emergencyContact: _emergencyContactController.text.trim().isEmpty
          ? null
          : _emergencyContactController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
          ? null
          : _emergencyPhoneController.text.trim(),
      healthGoals: existingProfile?.healthGoals ?? [],
      createdAt: existingProfile?.createdAt ?? now,
      updatedAt: now,
    );

    if (existingProfile == null) {
      context.read<ProfileBloc>().add(SaveProfile(profile));
    } else {
      context.read<ProfileBloc>().add(UpdateProfile(profile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? '创建档案' : '编辑档案'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('保存'),
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            Navigator.pop(context, true);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 基本信息
              _buildSectionTitle('基本信息'),
              const SizedBox(height: 12),
              _buildNicknameField(),
              const SizedBox(height: 12),
              _buildGenderSelector(),
              const SizedBox(height: 12),
              _buildBirthdayPicker(),
              const SizedBox(height: 24),

              // 身体数据
              _buildSectionTitle('身体数据'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildHeightField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildWeightField()),
                ],
              ),
              const SizedBox(height: 12),
              _buildBloodTypeSelector(),
              const SizedBox(height: 24),

              // 健康信息
              _buildSectionTitle('健康信息'),
              const SizedBox(height: 12),
              _buildTagsField(
                label: '过敏源',
                tags: _allergies,
                onAdd: (tag) => setState(() => _allergies.add(tag)),
                onRemove: (tag) => setState(() => _allergies.remove(tag)),
                suggestions: ['花粉', '海鲜', '牛奶', '鸡蛋', '花生', '小麦', '大豆'],
              ),
              const SizedBox(height: 12),
              _buildTagsField(
                label: '慢性病史',
                tags: _chronicDiseases,
                onAdd: (tag) => setState(() => _chronicDiseases.add(tag)),
                onRemove: (tag) => setState(() => _chronicDiseases.remove(tag)),
                suggestions: ['高血压', '糖尿病', '心脏病', '哮喘', '关节炎'],
              ),
              const SizedBox(height: 12),
              _buildTagsField(
                label: '正在服用药物',
                tags: _medications,
                onAdd: (tag) => setState(() => _medications.add(tag)),
                onRemove: (tag) => setState(() => _medications.remove(tag)),
                suggestions: [],
              ),
              const SizedBox(height: 24),

              // 紧急联系人
              _buildSectionTitle('紧急联系人'),
              const SizedBox(height: 12),
              _buildEmergencyContactField(),
              const SizedBox(height: 12),
              _buildEmergencyPhoneField(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNicknameField() {
    return TextFormField(
      controller: _nicknameController,
      decoration: const InputDecoration(
        labelText: '昵称',
        hintText: '给自己取个昵称吧',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('性别'),
        const SizedBox(height: 8),
        Row(
          children: Gender.values.map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(gender.emoji),
                      const SizedBox(width: 4),
                      Text(gender.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGender = selected ? gender : null;
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBirthdayPicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthday ?? DateTime(1990),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _selectedBirthday = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '出生日期',
          prefixIcon: Icon(Icons.cake),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _selectedBirthday != null
              ? '${_selectedBirthday!.year}年${_selectedBirthday!.month}月${_selectedBirthday!.day}日'
              : '点击选择',
          style: TextStyle(
            color:
                _selectedBirthday != null ? null : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '身高',
        suffixText: 'cm',
        prefixIcon: Icon(Icons.height),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: '体重',
        suffixText: 'kg',
        prefixIcon: Icon(Icons.monitor_weight),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBloodTypeSelector() {
    return DropdownButtonFormField<BloodType>(
      value: _selectedBloodType,
      decoration: const InputDecoration(
        labelText: '血型',
        prefixIcon: Icon(Icons.bloodtype),
        border: OutlineInputBorder(),
      ),
      items: BloodType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedBloodType = value);
      },
    );
  }

  Widget _buildTagsField({
    required String label,
    required List<String> tags,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required List<String> suggestions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddTagDialog(
                label: label,
                suggestions: suggestions,
                onAdd: onAdd,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加'),
            ),
          ],
        ),
        if (tags.isEmpty)
          Text(
            '暂无$label',
            style: TextStyle(color: Colors.grey.shade500),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => onRemove(tag),
                deleteIconColor: Colors.grey.shade600,
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddTagDialog({
    required String label,
    required List<String> suggestions,
    required Function(String) onAdd,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('添加$label'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '请输入$label',
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('常见选项:'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.map((s) {
                    return ActionChip(
                      label: Text(s),
                      onPressed: () {
                        onAdd(s);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onAdd(controller.text.trim());
                }
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmergencyContactField() {
    return TextFormField(
      controller: _emergencyContactController,
      decoration: const InputDecoration(
        labelText: '紧急联系人姓名',
        prefixIcon: Icon(Icons.contact_emergency),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildEmergencyPhoneField() {
    return TextFormField(
      controller: _emergencyPhoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: '紧急联系人电话',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
    );
  }
}
