# Flutter Demo Monorepo

一个包含 Flutter 移动端和 Node.js 服务端的 Monorepo 项目。

## 项目结构

```
.
├── apps/
│   ├── mobile/          # Flutter 移动端应用
│   │   ├── lib/
│   │   ├── pubspec.yaml
│   │   └── ...
│   └── server/          # Node.js 服务端
│       ├── src/
│       ├── package.json
│       └── ...
├── docs/                # 项目文档
└── README.md
```

## 快速开始

### 移动端 (Flutter)

```bash
cd apps/mobile

# 安装依赖
flutter pub get

# 生成代码
flutter pub run build_runner build --delete-conflicting-outputs

# 运行项目
flutter run
```

### 服务端 (Node.js)

```bash
cd apps/server

# 安装依赖
npm install

# 开发模式运行
npm run dev

# 生产构建
npm run build
npm start
```

## 移动端架构 (Clean Architecture)

```
apps/mobile/lib/
├── core/                    # 核心功能
│   ├── constants/          # 常量定义
│   ├── error/              # 错误处理
│   ├── network/            # 网络配置
│   ├── utils/              # 工具类
│   └── di/                 # 依赖注入
├── features/               # 功能模块
│   └── [feature_name]/
│       ├── data/           # 数据层
│       ├── domain/         # 领域层
│       └── presentation/   # 表现层
└── main.dart              # 应用入口
```

## 服务端架构

```
apps/server/src/
├── index.ts               # 应用入口
├── routes/                # 路由定义
├── controllers/           # 控制器
├── services/              # 业务逻辑
└── middleware/            # 中间件
```

## 开发说明

- 移动端使用 Flutter + BLoC 状态管理
- 服务端使用 Express + TypeScript
- 项目采用 Monorepo 结构便于统一管理
