# 快速开始指南

## 1. 环境准备

确保已安装以下工具：
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Git

## 2. 安装依赖

```bash
flutter pub get
```

## 3. 生成代码

项目使用了代码生成工具，需要运行以下命令生成必要的文件：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 4. 运行项目

```bash
flutter run
```

## 5. 运行测试

```bash
flutter test
```

## 6. 代码检查

```bash
flutter analyze
```

## 常用命令

### 代码生成
```bash
# 生成代码（删除冲突文件）
flutter pub run build_runner build --delete-conflicting-outputs

# 监听模式（自动生成）
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 清理项目
```bash
# 清理构建文件
flutter clean

# 重新获取依赖
flutter pub get
```

### 格式化代码
```bash
flutter format lib/
```

## 项目配置

### 修改 API 地址

编辑 `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### 配置依赖注入

1. 在需要注入的类上添加 `@injectable` 注解
2. 运行代码生成命令
3. 在 `main.dart` 中调用 `configureDependencies()`

详细说明请参考 `ARCHITECTURE.md`。

## 下一步

- 阅读 `ARCHITECTURE.md` 了解架构设计
- 阅读 `PROJECT_STRUCTURE.md` 了解项目结构
- 查看 `lib/features/user/` 目录了解示例实现

