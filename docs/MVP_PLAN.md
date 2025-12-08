# AI 预防性健康教练 APP - MVP 开发规划

## 📋 产品愿景

**AI Health Coach** - 一款 AI 驱动的预防性健康管理应用，通过症状追踪、健康模拟和个性化干预，帮助用户实现"未病先防"。

---

## 🎯 MVP 功能范围 (Phase 1)

基于"用户价值最大化 + 开发成本最小化"原则，MVP 聚焦以下核心功能：

### ✅ MVP 包含 (Must Have)

| 模块 | 功能 | 用户价值 |
|------|------|----------|
| **症状追踪** | 文本输入症状记录 | 快速记录身体状况 |
| **健康日记** | 每日健康数据汇总 | 可视化健康趋势 |
| **基础分析** | 症状频率/模式识别 | 发现潜在健康问题 |
| **健康评估** | 基于规则的风险评估 | 初步了解健康风险 |
| **用户档案** | 基本信息/健康背景 | 个性化基础 |
| **数据存储** | 本地加密存储 | 隐私保护 |

### ⏳ Phase 2 (后续迭代)

| 功能 | 优先级 |
|------|--------|
| 穿戴设备数据集成 (Apple Health/华为健康) | P1 |
| 语音输入症状 | P1 |
| Monte Carlo 模拟引擎 | P2 |
| AI 个性化建议 (接入 LLM API) | P2 |
| AR 姿势指导 | P3 |
| 社区功能 | P3 |
| Web3 激励机制 | P3 |

---

## 🏗️ Flutter 模块架构

基于现有 Clean Architecture，规划以下 Feature 模块：

```
lib/
├── core/                          # 核心基础设施 (已有)
│   ├── constants/
│   ├── di/
│   ├── error/
│   ├── network/
│   ├── utils/
│   └── theme/                     # [新增] 健康主题配色
│
├── features/
│   ├── user/                      # 用户模块 (已有，扩展)
│   │
│   ├── auth/                      # [新增] 认证模块
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── health_profile/            # [新增] 健康档案模块
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── health_profile.dart
│   │   │       ├── medical_history.dart
│   │   │       └── lifestyle_info.dart
│   │   └── presentation/
│   │
│   ├── symptom_tracker/           # [新增] 症状追踪模块 ⭐核心
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── symptom_local_datasource.dart
│   │   │   │   └── symptom_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── symptom_entry_model.dart
│   │   │   │   └── symptom_category_model.dart
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── symptom_entry.dart
│   │   │   │   ├── symptom_category.dart
│   │   │   │   └── body_part.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │       ├── add_symptom.dart
│   │   │       ├── get_symptoms_by_date.dart
│   │   │       ├── get_symptom_history.dart
│   │   │       └── analyze_symptom_patterns.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   ├── symptom_input_page.dart
│   │       │   └── symptom_history_page.dart
│   │       └── widgets/
│   │           ├── body_map_selector.dart
│   │           ├── severity_slider.dart
│   │           └── symptom_chip.dart
│   │
│   ├── health_diary/              # [新增] 健康日记模块
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── diary_entry.dart
│   │   │       └── daily_summary.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   ├── diary_home_page.dart
│   │       │   ├── diary_detail_page.dart
│   │       │   └── calendar_view_page.dart
│   │       └── widgets/
│   │           ├── mood_picker.dart
│   │           ├── sleep_tracker.dart
│   │           └── daily_stats_card.dart
│   │
│   ├── health_assessment/         # [新增] 健康评估模块
│   │   ├── data/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── risk_assessment.dart
│   │   │   │   └── health_score.dart
│   │   │   └── usecases/
│   │   │       ├── calculate_health_score.dart
│   │   │       └── generate_risk_report.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   └── assessment_result_page.dart
│   │       └── widgets/
│   │           ├── health_score_gauge.dart
│   │           └── risk_indicator.dart
│   │
│   └── dashboard/                 # [新增] 仪表盘模块
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           │   └── dashboard_page.dart
│           └── widgets/
│               ├── health_overview_card.dart
│               ├── recent_symptoms_list.dart
│               └── weekly_trend_chart.dart
│
├── shared/                        # [新增] 共享组件
│   ├── widgets/
│   │   ├── custom_app_bar.dart
│   │   ├── bottom_nav_bar.dart
│   │   └── health_card.dart
│   └── utils/
│       ├── date_utils.dart
│       └── health_utils.dart
│
└── main.dart
```

---

## 🔧 技术选型

### 现有依赖 (保留)
```yaml
# 状态管理
flutter_bloc: ^8.1.3
equatable: ^2.0.5

# 函数式编程
dartz: ^0.10.1

# 依赖注入
get_it: ^7.6.4
injectable: ^2.3.2

# 网络
dio: ^5.4.0
retrofit: ^4.0.3

# 本地存储
hive: ^2.2.3
hive_flutter: ^1.1.0
```

### 新增依赖 (MVP 需要)
```yaml
# UI 组件
fl_chart: ^0.68.0              # 健康数据图表
table_calendar: ^3.0.9         # 日历视图
flutter_svg: ^2.0.9            # SVG 人体图
percent_indicator: ^4.2.3      # 健康评分仪表盘

# 数据处理
intl: ^0.19.0                  # 日期格式化
uuid: ^4.2.2                   # 唯一标识生成

# 本地安全
flutter_secure_storage: ^9.0.0 # 加密存储敏感数据

# 通知
flutter_local_notifications: ^17.0.0  # 健康提醒

# 工具
logger: ^2.0.2                 # 日志记录
```

### Phase 2 依赖 (后续添加)
```yaml
# 语音输入
speech_to_text: ^6.6.0

# 穿戴设备集成
health: ^10.0.0                # Apple Health / Google Fit

# AI 集成
tflite_flutter: ^0.10.4        # TensorFlow Lite (端侧 AI)
dart_openai: ^5.1.0            # OpenAI API (云端 AI)
```

---

## 📊 核心数据模型

### 1. SymptomEntry (症状记录)
```dart
class SymptomEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final String symptomName;        // 症状名称
  final SymptomCategory category;  // 分类 (头部/胸部/腹部等)
  final int severity;              // 严重程度 1-10
  final Duration duration;         // 持续时间
  final List<String> bodyParts;    // 涉及部位
  final String? notes;             // 备注
  final List<String>? triggers;    // 可能诱因
  final Map<String, dynamic>? metadata;
}
```

### 2. HealthProfile (健康档案)
```dart
class HealthProfile extends Equatable {
  final String userId;
  final DateTime birthDate;
  final Gender gender;
  final double height;             // cm
  final double weight;             // kg
  final BloodType? bloodType;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> medications;
  final List<FamilyMedicalHistory> familyHistory;
  final LifestyleInfo lifestyle;
}
```

### 3. DiaryEntry (日记条目)
```dart
class DiaryEntry extends Equatable {
  final String id;
  final DateTime date;
  final MoodLevel mood;            // 心情 1-5
  final double? sleepHours;
  final int? sleepQuality;         // 1-5
  final int? stressLevel;          // 1-10
  final int? energyLevel;          // 1-10
  final List<String> activities;
  final List<SymptomEntry> symptoms;
  final String? notes;
  final Map<String, dynamic>? vitals;  // 生命体征 (心率/血压等)
}
```

### 4. HealthScore (健康评分)
```dart
class HealthScore extends Equatable {
  final double overallScore;       // 0-100
  final DateTime calculatedAt;
  final Map<String, double> categoryScores;  // 各维度评分
  final List<RiskFactor> riskFactors;
  final List<String> recommendations;
  final TrendDirection trend;      // 上升/下降/稳定
}
```

---

## 📝 开发任务清单

### Phase 1.0 - 基础架构 (Week 1-2)

#### 1.1 项目初始化
- [ ] 更新 pubspec.yaml，添加新依赖
- [ ] 运行 `flutter pub get`
- [ ] 配置代码生成 (build_runner)
- [ ] 创建统一主题配置 (健康绿色调)
- [ ] 设置应用图标和启动页

#### 1.2 核心基础设施
- [ ] 扩展 Hive 配置，注册新的 TypeAdapter
- [ ] 创建加密存储服务 (SecureStorageService)
- [ ] 配置路由管理 (go_router 或 auto_route)
- [ ] 创建底部导航栏框架
- [ ] 实现主题切换 (浅色/深色)

#### 1.3 共享组件
- [ ] 创建 HealthCard 基础卡片组件
- [ ] 创建 CustomAppBar 统一顶栏
- [ ] 创建 LoadingOverlay 加载遮罩
- [ ] 创建 EmptyState 空状态组件
- [ ] 创建 ErrorDisplay 错误展示组件

---

### Phase 1.1 - 健康档案模块 (Week 2-3)

#### Domain 层
- [ ] 创建 HealthProfile Entity
- [ ] 创建 MedicalHistory Entity
- [ ] 创建 LifestyleInfo Entity
- [ ] 定义 HealthProfileRepository 接口
- [ ] 实现 CreateProfile UseCase
- [ ] 实现 UpdateProfile UseCase
- [ ] 实现 GetProfile UseCase

#### Data 层
- [ ] 创建 HealthProfileModel (Hive 适配)
- [ ] 实现 HealthProfileLocalDataSource
- [ ] 实现 HealthProfileRepositoryImpl

#### Presentation 层
- [ ] 创建 HealthProfileBloc
- [ ] 创建 ProfileSetupPage (引导页)
- [ ] 创建 ProfileEditPage
- [ ] 创建 BasicInfoForm Widget
- [ ] 创建 MedicalHistoryForm Widget
- [ ] 创建 LifestyleForm Widget

---

### Phase 1.2 - 症状追踪模块 (Week 3-4) ⭐核心

#### Domain 层
- [ ] 创建 SymptomEntry Entity
- [ ] 创建 SymptomCategory Entity
- [ ] 创建 BodyPart Enum
- [ ] 定义 SymptomRepository 接口
- [ ] 实现 AddSymptom UseCase
- [ ] 实现 GetSymptomsByDateRange UseCase
- [ ] 实现 GetSymptomHistory UseCase
- [ ] 实现 DeleteSymptom UseCase

#### Data 层
- [ ] 创建 SymptomEntryModel (Hive)
- [ ] 创建 SymptomCategoryModel
- [ ] 实现 SymptomLocalDataSource
- [ ] 实现 SymptomRepositoryImpl
- [ ] 创建预置症状数据 (JSON)

#### Presentation 层
- [ ] 创建 SymptomBloc
- [ ] 创建 SymptomEvent 定义
- [ ] 创建 SymptomState 定义
- [ ] 创建 SymptomInputPage (主输入页)
- [ ] 创建 BodyMapSelector Widget (人体图选择)
- [ ] 创建 SymptomSearchField Widget (搜索/自动补全)
- [ ] 创建 SeveritySlider Widget (严重程度滑块)
- [ ] 创建 DurationPicker Widget
- [ ] 创建 SymptomHistoryPage
- [ ] 创建 SymptomDetailPage
- [ ] 创建 SymptomChip Widget
- [ ] 创建 SymptomListTile Widget

---

### Phase 1.3 - 健康日记模块 (Week 4-5)

#### Domain 层
- [ ] 创建 DiaryEntry Entity
- [ ] 创建 DailySummary Entity
- [ ] 创建 MoodLevel Enum
- [ ] 定义 DiaryRepository 接口
- [ ] 实现 CreateDiaryEntry UseCase
- [ ] 实现 GetDiaryByDate UseCase
- [ ] 实现 GetDiarySummary UseCase

#### Data 层
- [ ] 创建 DiaryEntryModel (Hive)
- [ ] 实现 DiaryLocalDataSource
- [ ] 实现 DiaryRepositoryImpl

#### Presentation 层
- [ ] 创建 DiaryBloc
- [ ] 创建 DiaryHomePage
- [ ] 创建 DiaryEntryPage (新建/编辑)
- [ ] 创建 CalendarViewPage
- [ ] 创建 MoodPicker Widget
- [ ] 创建 SleepTracker Widget
- [ ] 创建 DailyStatsCard Widget
- [ ] 创建 DiaryTimeline Widget

---

### Phase 1.4 - 健康评估模块 (Week 5-6)

#### Domain 层
- [ ] 创建 HealthScore Entity
- [ ] 创建 RiskAssessment Entity
- [ ] 创建 RiskFactor Entity
- [ ] 定义 AssessmentRepository 接口
- [ ] 实现 CalculateHealthScore UseCase
- [ ] 实现 GenerateRiskReport UseCase
- [ ] 创建规则引擎 (RuleBasedAnalyzer)

#### Data 层
- [ ] 创建健康评估规则配置 (JSON)
- [ ] 实现 AssessmentLocalDataSource
- [ ] 实现 AssessmentRepositoryImpl

#### Presentation 层
- [ ] 创建 AssessmentBloc
- [ ] 创建 AssessmentResultPage
- [ ] 创建 HealthScoreGauge Widget
- [ ] 创建 RiskIndicator Widget
- [ ] 创建 RecommendationCard Widget
- [ ] 创建 TrendChart Widget

---

### Phase 1.5 - 仪表盘与整合 (Week 6-7)

#### Presentation 层
- [ ] 创建 DashboardBloc
- [ ] 创建 DashboardPage (首页)
- [ ] 创建 HealthOverviewCard Widget
- [ ] 创建 RecentSymptomsWidget
- [ ] 创建 WeeklyTrendChart Widget
- [ ] 创建 QuickActionButtons Widget
- [ ] 创建 HealthTipsCard Widget

#### 整合与优化
- [ ] 实现模块间数据流
- [ ] 配置依赖注入 (Injectable)
- [ ] 添加页面转场动画
- [ ] 实现本地通知提醒
- [ ] 添加数据导出功能 (JSON)
- [ ] 性能优化与测试

---

### Phase 1.6 - 测试与上线准备 (Week 7-8)

#### 测试
- [ ] 编写 Domain 层单元测试
- [ ] 编写 Repository 集成测试
- [ ] 编写 Bloc 单元测试
- [ ] 编写 Widget 测试
- [ ] 进行 UI/UX 测试

#### 上线准备
- [ ] 隐私政策页面
- [ ] 用户协议页面
- [ ] 应用商店元数据
- [ ] 截图与宣传图
- [ ] APK/IPA 打包测试

---

## 📅 里程碑

| 里程碑 | 交付物 | 验收标准 |
|--------|--------|----------|
| M1 | 基础架构完成 | 项目可运行，导航框架正常 |
| M2 | 健康档案可用 | 用户可创建/编辑个人档案 |
| M3 | 症状追踪可用 | 用户可记录/查看症状历史 |
| M4 | 健康日记可用 | 用户可记录每日健康状态 |
| M5 | 健康评估可用 | 用户可查看健康评分报告 |
| M6 | MVP 完成 | 功能整合，可进行内测 |

---

## 🎨 UI/UX 设计建议

### 配色方案
```dart
// 主色调 - 健康绿
static const primaryColor = Color(0xFF4CAF50);
static const primaryLight = Color(0xFF81C784);
static const primaryDark = Color(0xFF388E3C);

// 辅助色
static const accentColor = Color(0xFF03A9F4);   // 蓝色 - 数据/图表
static const warningColor = Color(0xFFFF9800);  // 橙色 - 警告
static const dangerColor = Color(0xFFF44336);   // 红色 - 高风险

// 心情颜色
static const moodColors = [
  Color(0xFFE57373),  // 1 - 很差
  Color(0xFFFFB74D),  // 2 - 较差
  Color(0xFFFFF176),  // 3 - 一般
  Color(0xFFAED581),  // 4 - 较好
  Color(0xFF81C784),  // 5 - 很好
];
```

### 核心页面线框图

```
┌─────────────────────────────────┐
│         Dashboard 首页          │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │   Health Score: 78      │   │
│  │   ████████████░░░░      │   │
│  │   趋势: ↑ 较上周提升5%   │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │   今日概览               │   │
│  │   😊 心情良好            │   │
│  │   💤 睡眠 7.5h          │   │
│  │   🏃 活动 8,000 步       │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │   最近症状               │   │
│  │   • 头痛 (轻微) - 今天   │   │
│  │   • 疲劳 (中等) - 昨天   │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌──────┐  ┌──────┐           │
│  │+记录 │  │ 日记 │           │
│  │ 症状 │  │      │           │
│  └──────┘  └──────┘           │
│                                 │
├─────────────────────────────────┤
│  🏠    📊    ➕    📅    👤    │
│  首页  分析  记录  日记  我的  │
└─────────────────────────────────┘
```

---

## ⚠️ 风险与应对

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 医疗合规性 | 高 | 明确声明"非医疗诊断工具"，添加免责声明 |
| 数据隐私 | 高 | 本地存储优先，加密敏感数据，符合 GDPR |
| 功能膨胀 | 中 | 严格按 MVP 范围开发，延后非核心功能 |
| 用户留存 | 中 | 设计每日提醒，游戏化元素 (Phase 2) |

---

## 🔗 参考资源

- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [fl_chart 文档](https://pub.dev/packages/fl_chart)
- [Hive 数据库](https://docs.hivedb.dev/)
- [健康数据标准 FHIR](https://www.hl7.org/fhir/)

---

*文档版本: 1.0.0 | 更新日期: 2025-12-08*
