import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/health_goal.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/health_goal_card.dart';
import 'edit_profile_page.dart';
import 'add_goal_page.dart';
import '../../../export/presentation/pages/export_page.dart';
import '../../../reminders/presentation/pages/reminder_settings_page.dart';
import '../../../achievements/presentation/pages/achievements_page.dart';
import '../../../backup/presentation/pages/backup_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_provider.dart';

/// 个人中心页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  Future<void> _openEditProfile(UserProfile? profile) async {
    final bloc = context.read<ProfileBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: EditProfilePage(profile: profile),
        ),
      ),
    );
    if (result == true) {
      bloc.add(const LoadProfile());
    }
  }

  Future<void> _openAddGoal() async {
    final bloc = context.read<ProfileBloc>();
    final state = bloc.state;
    UserProfile? profile;
    if (state is ProfileLoaded) {
      profile = state.profile;
    }

    final result = await Navigator.push<HealthGoal>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddGoalPage(existingGoals: profile?.healthGoals ?? []),
        ),
      ),
    );

    if (result != null) {
      bloc.add(AddGoal(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          UserProfile? profile;
          if (state is ProfileLoaded) {
            profile = state.profile;
          } else if (state is ProfileSaved) {
            profile = state.profile;
          } else if (state is GoalUpdated) {
            profile = state.profile;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const LoadProfile());
            },
            child: CustomScrollView(
              slivers: [
                // 头部
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    profile: profile,
                    onEditTap: () => _openEditProfile(profile),
                  ),
                ),

                // 内容
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // BMI 卡片
                      if (profile?.bmi != null) ...[
                        _buildBmiCard(profile!),
                        const SizedBox(height: 16),
                      ],

                      // 健康目标
                      _buildSectionTitle('健康目标', onAdd: _openAddGoal),
                      const SizedBox(height: 8),
                      if (profile?.healthGoals.isEmpty ?? true) ...[
                        AddGoalCard(onTap: _openAddGoal),
                      ] else ...[
                        ...profile!.healthGoals.map((goal) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: HealthGoalCard(
                                goal: goal,
                                onProgressUpdate: (value) {
                                  context.read<ProfileBloc>().add(
                                        UpdateProgress(goal.id, value),
                                      );
                                },
                                onDelete: () {
                                  context
                                      .read<ProfileBloc>()
                                      .add(DeleteGoal(goal.id));
                                },
                              ),
                            )),
                      ],
                      const SizedBox(height: 16),

                      // 健康档案信息
                      _buildSectionTitle('健康档案'),
                      const SizedBox(height: 8),
                      _buildHealthInfoCard(profile),
                      const SizedBox(height: 16),

                      // 设置
                      _buildSectionTitle('设置'),
                      const SizedBox(height: 8),
                      _buildSettingsCard(),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onAdd}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (onAdd != null)
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加'),
          ),
      ],
    );
  }

  Widget _buildBmiCard(UserProfile profile) {
    final bmiColor = Color(int.parse('0xFF${profile.bmiColorHex}'));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bmiColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  profile.bmi!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: bmiColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BMI 指数',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.bmiLevel} · ${profile.height?.toStringAsFixed(0)}cm / ${profile.weight?.toStringAsFixed(1)}kg',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bmiColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                profile.bmiLevel!,
                style: TextStyle(
                  color: bmiColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard(UserProfile? profile) {
    return Card(
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.warning_amber,
            title: '过敏源',
            value: profile?.allergies.isEmpty ?? true
                ? '未设置'
                : profile!.allergies.join(', '),
            color: Colors.orange,
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.medical_services,
            title: '慢性病史',
            value: profile?.chronicDiseases.isEmpty ?? true
                ? '无'
                : profile!.chronicDiseases.join(', '),
            color: Colors.red,
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.medication,
            title: '服用药物',
            value: profile?.medications.isEmpty ?? true
                ? '无'
                : profile!.medications.join(', '),
            color: Colors.blue,
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.phone,
            title: '紧急联系人',
            value: profile?.emergencyContact ?? '未设置',
            subtitle: profile?.emergencyPhone,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: value == '未设置' || value == '无'
                  ? Colors.grey.shade400
                  : Colors.black87,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
            title: const Text('我的成就'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AchievementsPage()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('提醒设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReminderSettingsPage()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('数据导出'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportPage()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined, color: Colors.blue),
            title: const Text('备份与同步'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupPage()),
              );
            },
          ),
          const Divider(height: 1),
          _buildThemeSettingsTile(),
          const Divider(height: 1),
          _buildLanguageSettingsTile(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'AI Health Coach',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 AI Health Coach',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsTile() {
    final themeProvider = ThemeProviderWidget.maybeOf(context);
    final currentMode = themeProvider?.themeMode ?? AppThemeMode.system;

    return ListTile(
      leading: Icon(
        currentMode.icon,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.amber
            : Colors.indigo,
      ),
      title: const Text('深色模式'),
      subtitle: Text(currentMode.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeSelectionDialog(themeProvider),
    );
  }

  void _showThemeSelectionDialog(ThemeProvider? themeProvider) {
    if (themeProvider == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            final isSelected = themeProvider.themeMode == mode;
            return ListTile(
              leading: Icon(
                mode.icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              title: Text(
                mode.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                themeProvider.setThemeMode(mode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettingsTile() {
    final localeProvider = LocaleProviderWidget.maybeOf(context);
    final currentLanguage = localeProvider?.language ?? AppLanguage.system;

    return ListTile(
      leading: const Icon(Icons.language, color: Colors.teal),
      title: Text(AppLocalizations.of(context).language),
      subtitle: Text(localeProvider?.getDisplayName(context) ?? currentLanguage.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageSelectionDialog(localeProvider),
    );
  }

  void _showLanguageSelectionDialog(LocaleProvider? localeProvider) {
    if (localeProvider == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSelected = localeProvider.language == lang;
            return ListTile(
              leading: Icon(
                lang == AppLanguage.system
                    ? Icons.phone_android
                    : Icons.language,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              title: Text(
                lang.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              subtitle: lang != AppLanguage.system
                  ? Text(
                      lang.englishName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    )
                  : null,
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                localeProvider.setLanguage(lang);
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).cancel),
          ),
        ],
      ),
    );
  }
}
