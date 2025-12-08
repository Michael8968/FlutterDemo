/// 心情等级
enum MoodLevel {
  veryBad(1, '很差', '😢', 'E57373'),
  bad(2, '较差', '😟', 'FFB74D'),
  neutral(3, '一般', '😐', 'FFF176'),
  good(4, '较好', '🙂', 'AED581'),
  veryGood(5, '很好', '😄', '81C784');

  final int value;
  final String displayName;
  final String emoji;
  final String colorHex;

  const MoodLevel(this.value, this.displayName, this.emoji, this.colorHex);

  static MoodLevel fromValue(int value) {
    return MoodLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => MoodLevel.neutral,
    );
  }
}

/// 睡眠质量
enum SleepQuality {
  veryPoor(1, '很差', '几乎没睡好'),
  poor(2, '较差', '睡眠断断续续'),
  fair(3, '一般', '睡眠质量中等'),
  good(4, '较好', '睡眠基本良好'),
  excellent(5, '很好', '睡眠深沉充足');

  final int value;
  final String displayName;
  final String description;

  const SleepQuality(this.value, this.displayName, this.description);

  static SleepQuality fromValue(int value) {
    return SleepQuality.values.firstWhere(
      (quality) => quality.value == value,
      orElse: () => SleepQuality.fair,
    );
  }
}

/// 活动类型
enum ActivityType {
  exercise('运动', '🏃'),
  work('工作', '💼'),
  study('学习', '📚'),
  social('社交', '👥'),
  entertainment('娱乐', '🎮'),
  rest('休息', '🛋️'),
  housework('家务', '🏠'),
  outdoor('户外', '🌳'),
  travel('旅行', '✈️'),
  meditation('冥想', '🧘'),
  reading('阅读', '📖'),
  cooking('烹饪', '🍳'),
  shopping('购物', '🛒'),
  other('其他', '📝');

  final String displayName;
  final String emoji;

  const ActivityType(this.displayName, this.emoji);
}

/// 天气类型
enum WeatherType {
  sunny('晴天', '☀️'),
  cloudy('多云', '⛅'),
  overcast('阴天', '☁️'),
  rainy('雨天', '🌧️'),
  snowy('雪天', '❄️'),
  windy('大风', '💨'),
  foggy('雾天', '🌫️'),
  hot('炎热', '🔥'),
  cold('寒冷', '🥶');

  final String displayName;
  final String emoji;

  const WeatherType(this.displayName, this.emoji);
}
