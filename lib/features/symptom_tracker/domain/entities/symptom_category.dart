import 'package:equatable/equatable.dart';

/// 症状分类
enum SymptomType {
  pain('疼痛', '🔴'),
  discomfort('不适', '🟠'),
  fatigue('疲劳', '🟡'),
  digestive('消化', '🟢'),
  respiratory('呼吸', '🔵'),
  skin('皮肤', '🟣'),
  mental('精神/情绪', '🟤'),
  fever('发热', '🌡️'),
  other('其他', '⚪');

  final String displayName;
  final String emoji;

  const SymptomType(this.displayName, this.emoji);
}

/// 症状严重程度
enum SeverityLevel {
  mild(1, '轻微', '症状轻微，不影响日常活动'),
  moderate(2, '中等', '症状明显，部分影响日常活动'),
  severe(3, '严重', '症状严重，明显影响日常活动'),
  critical(4, '非常严重', '症状剧烈，无法进行日常活动');

  final int level;
  final String displayName;
  final String description;

  const SeverityLevel(this.level, this.displayName, this.description);

  static SeverityLevel fromScore(int score) {
    if (score <= 3) return SeverityLevel.mild;
    if (score <= 5) return SeverityLevel.moderate;
    if (score <= 8) return SeverityLevel.severe;
    return SeverityLevel.critical;
  }
}

/// 预置症状模板
class SymptomTemplate extends Equatable {
  final String id;
  final String name;
  final SymptomType type;
  final List<String> commonBodyParts;
  final List<String> commonTriggers;
  final String? description;

  const SymptomTemplate({
    required this.id,
    required this.name,
    required this.type,
    this.commonBodyParts = const [],
    this.commonTriggers = const [],
    this.description,
  });

  @override
  List<Object?> get props => [id, name, type, commonBodyParts, commonTriggers];
}

/// 预置症状列表
class SymptomTemplates {
  static const List<SymptomTemplate> all = [
    // 疼痛类
    SymptomTemplate(
      id: 'headache',
      name: '头痛',
      type: SymptomType.pain,
      commonBodyParts: ['head', 'temple', 'forehead'],
      commonTriggers: ['压力', '睡眠不足', '用眼过度', '天气变化'],
    ),
    SymptomTemplate(
      id: 'stomachache',
      name: '胃痛',
      type: SymptomType.pain,
      commonBodyParts: ['stomach', 'abdomen'],
      commonTriggers: ['饮食不当', '饥饿', '压力', '辛辣食物'],
    ),
    SymptomTemplate(
      id: 'backpain',
      name: '腰背痛',
      type: SymptomType.pain,
      commonBodyParts: ['lowerBack', 'upperBack', 'spine'],
      commonTriggers: ['久坐', '姿势不当', '运动过度', '搬重物'],
    ),
    SymptomTemplate(
      id: 'jointpain',
      name: '关节痛',
      type: SymptomType.pain,
      commonBodyParts: ['joint', 'knee', 'shoulder', 'wrist'],
      commonTriggers: ['天气变化', '运动', '劳累'],
    ),
    SymptomTemplate(
      id: 'chestpain',
      name: '胸痛',
      type: SymptomType.pain,
      commonBodyParts: ['chest', 'heart'],
      commonTriggers: ['运动', '压力', '呼吸深'],
    ),

    // 不适类
    SymptomTemplate(
      id: 'dizziness',
      name: '头晕',
      type: SymptomType.discomfort,
      commonBodyParts: ['head'],
      commonTriggers: ['起身过快', '低血糖', '睡眠不足', '脱水'],
    ),
    SymptomTemplate(
      id: 'nausea',
      name: '恶心',
      type: SymptomType.discomfort,
      commonBodyParts: ['stomach'],
      commonTriggers: ['饮食不当', '晕车', '怀孕', '药物'],
    ),
    SymptomTemplate(
      id: 'numbness',
      name: '麻木',
      type: SymptomType.discomfort,
      commonBodyParts: ['hand', 'foot', 'finger', 'toe'],
      commonTriggers: ['压迫', '久坐', '受凉'],
    ),

    // 疲劳类
    SymptomTemplate(
      id: 'fatigue',
      name: '疲劳',
      type: SymptomType.fatigue,
      commonBodyParts: ['wholeBody'],
      commonTriggers: ['睡眠不足', '工作压力', '运动过度', '营养不良'],
    ),
    SymptomTemplate(
      id: 'insomnia',
      name: '失眠',
      type: SymptomType.fatigue,
      commonBodyParts: ['head'],
      commonTriggers: ['压力', '咖啡因', '手机', '焦虑'],
    ),
    SymptomTemplate(
      id: 'weakness',
      name: '乏力',
      type: SymptomType.fatigue,
      commonBodyParts: ['wholeBody', 'muscle'],
      commonTriggers: ['生病', '营养不良', '缺乏运动'],
    ),

    // 消化类
    SymptomTemplate(
      id: 'bloating',
      name: '腹胀',
      type: SymptomType.digestive,
      commonBodyParts: ['abdomen', 'stomach'],
      commonTriggers: ['进食过快', '产气食物', '便秘'],
    ),
    SymptomTemplate(
      id: 'diarrhea',
      name: '腹泻',
      type: SymptomType.digestive,
      commonBodyParts: ['intestine', 'abdomen'],
      commonTriggers: ['食物不洁', '受凉', '压力'],
    ),
    SymptomTemplate(
      id: 'constipation',
      name: '便秘',
      type: SymptomType.digestive,
      commonBodyParts: ['intestine', 'lowerAbdomen'],
      commonTriggers: ['饮水不足', '缺乏纤维', '久坐'],
    ),
    SymptomTemplate(
      id: 'heartburn',
      name: '烧心/反酸',
      type: SymptomType.digestive,
      commonBodyParts: ['chest', 'throat', 'stomach'],
      commonTriggers: ['辛辣食物', '饱餐后躺下', '咖啡'],
    ),

    // 呼吸类
    SymptomTemplate(
      id: 'cough',
      name: '咳嗽',
      type: SymptomType.respiratory,
      commonBodyParts: ['throat', 'chest', 'lung'],
      commonTriggers: ['感冒', '过敏', '空气污染', '干燥'],
    ),
    SymptomTemplate(
      id: 'shortnessOfBreath',
      name: '气短',
      type: SymptomType.respiratory,
      commonBodyParts: ['chest', 'lung'],
      commonTriggers: ['运动', '焦虑', '高海拔'],
    ),
    SymptomTemplate(
      id: 'nasalCongestion',
      name: '鼻塞',
      type: SymptomType.respiratory,
      commonBodyParts: ['nose'],
      commonTriggers: ['感冒', '过敏', '干燥'],
    ),
    SymptomTemplate(
      id: 'soreThroat',
      name: '咽喉痛',
      type: SymptomType.respiratory,
      commonBodyParts: ['throat'],
      commonTriggers: ['感冒', '用嗓过度', '干燥'],
    ),

    // 皮肤类
    SymptomTemplate(
      id: 'rash',
      name: '皮疹',
      type: SymptomType.skin,
      commonBodyParts: ['skin'],
      commonTriggers: ['过敏', '食物', '药物', '接触物'],
    ),
    SymptomTemplate(
      id: 'itching',
      name: '瘙痒',
      type: SymptomType.skin,
      commonBodyParts: ['skin'],
      commonTriggers: ['干燥', '过敏', '蚊虫叮咬'],
    ),

    // 精神/情绪类
    SymptomTemplate(
      id: 'anxiety',
      name: '焦虑',
      type: SymptomType.mental,
      commonBodyParts: ['head', 'chest'],
      commonTriggers: ['工作压力', '考试', '人际关系', '未来担忧'],
    ),
    SymptomTemplate(
      id: 'depression',
      name: '情绪低落',
      type: SymptomType.mental,
      commonBodyParts: ['head'],
      commonTriggers: ['压力', '季节变化', '生活事件'],
    ),
    SymptomTemplate(
      id: 'stressFeeling',
      name: '压力感',
      type: SymptomType.mental,
      commonBodyParts: ['head', 'shoulder', 'neck'],
      commonTriggers: ['工作', '学业', '家庭', '经济'],
    ),

    // 发热类
    SymptomTemplate(
      id: 'fever',
      name: '发烧',
      type: SymptomType.fever,
      commonBodyParts: ['wholeBody'],
      commonTriggers: ['感染', '感冒', '炎症'],
    ),
    SymptomTemplate(
      id: 'chills',
      name: '发冷/寒战',
      type: SymptomType.fever,
      commonBodyParts: ['wholeBody'],
      commonTriggers: ['发烧前兆', '受凉', '感染'],
    ),
  ];

  static List<SymptomTemplate> getByType(SymptomType type) {
    return all.where((t) => t.type == type).toList();
  }

  static SymptomTemplate? findById(String id) {
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<SymptomTemplate> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((t) => t.name.toLowerCase().contains(lowerQuery)).toList();
  }
}
