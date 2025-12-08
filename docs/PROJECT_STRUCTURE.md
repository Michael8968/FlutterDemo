# 项目结构说明

## 目录结构

```
FlutterDemo/
├── lib/                          # 源代码目录
│   ├── core/                     # 核心功能模块
│   │   ├── constants/            # 常量定义
│   │   │   └── app_constants.dart
│   │   ├── di/                   # 依赖注入
│   │   │   ├── injection.dart
│   │   │   ├── injection.config.dart (生成)
│   │   │   └── module.dart
│   │   ├── error/                # 错误处理
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/              # 网络相关
│   │   │   ├── api_client.dart
│   │   │   ├── api_service.dart
│   │   │   └── api_service.g.dart (生成)
│   │   └── utils/                # 工具类
│   │       ├── extension.dart
│   │       └── input_validator.dart
│   ├── features/                 # 功能模块
│   │   └── user/                 # 用户功能模块（示例）
│   │       ├── data/             # 数据层
│   │       │   ├── datasources/ # 数据源
│   │       │   │   ├── user_local_datasource.dart
│   │       │   │   └── user_remote_datasource.dart
│   │       │   ├── models/       # 数据模型
│   │       │   │   ├── user_model.dart
│   │       │   │   └── user_model.g.dart (生成)
│   │       │   └── repositories/ # 仓库实现
│   │       │       └── user_repository_impl.dart
│   │       ├── domain/           # 领域层
│   │       │   ├── entities/     # 实体
│   │       │   │   └── user.dart
│   │       │   ├── repositories/ # 仓库接口
│   │       │   │   └── user_repository.dart
│   │       │   └── usecases/     # 用例
│   │       │       ├── get_all_users.dart
│   │       │       └── get_user_by_id.dart
│   │       └── presentation/     # 表现层
│   │           ├── bloc/         # 状态管理
│   │           │   ├── user_bloc.dart
│   │           │   ├── user_event.dart
│   │           │   └── user_state.dart
│   │           ├── pages/        # 页面
│   │           │   └── user_list_page.dart
│   │           └── widgets/      # 组件
│   │               ├── error_message.dart
│   │               ├── loading_indicator.dart
│   │               └── user_list_item.dart
│   └── main.dart                 # 应用入口
├── test/                         # 测试目录
│   └── features/
│       └── user/
│           └── domain/
│               └── usecases/
│                   ├── get_user_by_id_test.dart
│                   └── get_user_by_id_test.mocks.dart (生成)
├── pubspec.yaml                  # 项目配置
├── analysis_options.yaml         # 代码分析配置
├── build.yaml                    # 构建配置
├── .gitignore                    # Git 忽略文件
├── README.md                     # 项目说明
├── ARCHITECTURE.md               # 架构说明文档
└── PROJECT_STRUCTURE.md          # 项目结构说明（本文件）
```

## 文件说明

### 核心文件

- **pubspec.yaml**: 项目依赖配置
- **analysis_options.yaml**: Dart 代码分析规则配置
- **build.yaml**: 代码生成工具配置
- **main.dart**: 应用入口文件

### Core 模块

- **constants/**: 应用常量（API 地址、超时时间等）
- **di/**: 依赖注入配置
- **error/**: 错误处理（异常和失败类型）
- **network/**: 网络请求封装
- **utils/**: 工具类和扩展方法

### Feature 模块结构

每个功能模块（如 `user`）都遵循 Clean Architecture 的三层结构：

1. **domain/**: 业务逻辑层（不依赖外部框架）
2. **data/**: 数据层（实现 domain 层定义的接口）
3. **presentation/**: 表现层（UI 和状态管理）

## 代码生成文件

以下文件需要通过 `flutter pub run build_runner build` 生成：

- `lib/core/di/injection.config.dart`
- `lib/core/network/api_service.g.dart`
- `lib/features/user/data/models/user_model.g.dart`
- `test/features/user/domain/usecases/get_user_by_id_test.mocks.dart`

## 添加新功能模块

1. 在 `lib/features/` 下创建新模块目录
2. 按照三层架构创建对应文件
3. 在 `lib/core/di/module.dart` 中注册依赖
4. 运行代码生成命令

详细步骤请参考 `ARCHITECTURE.md`。

