import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/share_service.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_summary_card.dart';

/// 成就页面
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementService? _achievementService;
  final ShareService _shareService = ShareService();

  List<UserAchievement> _allAchievements = [];
  AchievementSummary? _summary;
  AchievementCategory? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    final prefs = await SharedPreferences.getInstance();
    _achievementService = AchievementService(prefs);
    await _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (_achievementService == null) return;

    setState(() => _isLoading = true);

    final achievements = await _achievementService!.getAllAchievements();
    final summary = await _achievementService!.getAchievementSummary();

    setState(() {
      _allAchievements = achievements;
      _summary = summary;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成就系统'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _summary != null
                ? () => _shareService.shareAchievementSummary(_summary!)
                : null,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部成就'),
            Tab(text: '已解锁'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 成就摘要卡片
                if (_summary != null)
                  AchievementSummaryCard(
                    summary: _summary!,
                    onShareTap: () =>
                        _shareService.shareAchievementSummary(_summary!),
                  ),

                // 分类筛选
                _buildCategoryFilter(),

                // 成就列表
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllAchievementsList(),
                      _buildUnlockedAchievementsList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('全部'),
            selected: _selectedCategory == null,
            onSelected: (selected) {
              setState(() => _selectedCategory = null);
            },
          ),
          const SizedBox(width: 8),
          ...AchievementCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(category.icon, size: 16),
                label: Text(category.displayName),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
                selectedColor: category.color.withOpacity(0.2),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAllAchievementsList() {
    // 获取所有成就定义并与用户数据匹配
    final definitions = _selectedCategory != null
        ? AchievementDefinition.all
            .where((d) => d.category == _selectedCategory)
            .toList()
        : AchievementDefinition.all;

    if (definitions.isEmpty) {
      return _buildEmptyState('暂无该类型成就');
    }

    // 按类别分组
    final groupedDefinitions = <AchievementCategory, List<AchievementDefinition>>{};
    for (final def in definitions) {
      groupedDefinitions.putIfAbsent(def.category, () => []).add(def);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedDefinitions.length,
      itemBuilder: (context, index) {
        final category = groupedDefinitions.keys.elementAt(index);
        final categoryDefs = groupedDefinitions[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类标题
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(category.icon, color: category.color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ],
              ),
            ),
            // 成就卡片
            ...categoryDefs.map((def) {
              final userAchievement = _allAchievements
                  .where((a) => a.definitionId == def.id)
                  .firstOrNull;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AchievementCard(
                  definition: def,
                  userAchievement: userAchievement,
                  onShare: userAchievement?.isUnlocked == true
                      ? () => _shareService.shareAchievement(userAchievement!)
                      : null,
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildUnlockedAchievementsList() {
    var unlockedAchievements =
        _allAchievements.where((a) => a.isUnlocked).toList();

    // 筛选分类
    if (_selectedCategory != null) {
      unlockedAchievements = unlockedAchievements
          .where((a) => a.definition?.category == _selectedCategory)
          .toList();
    }

    // 按解锁时间排序
    unlockedAchievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));

    if (unlockedAchievements.isEmpty) {
      return _buildEmptyState('还没有解锁的成就\n继续努力吧！');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unlockedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = unlockedAchievements[index];
        final definition = achievement.definition;
        if (definition == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AchievementCard(
            definition: definition,
            userAchievement: achievement,
            onShare: () => _shareService.shareAchievement(achievement),
            showUnlockTime: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
