# Clean Architecture 使用指南

## 架构层次说明

### 1. Domain Layer (领域层)
**位置**: `lib/features/[feature_name]/domain/`

这是最内层的核心业务逻辑层，不依赖任何外部框架。

- **Entities**: 纯 Dart 类，表示业务实体
- **Repositories**: 仓库接口定义（抽象类）
- **Use Cases**: 业务用例，每个用例只做一件事

**示例**:
```dart
// entities/user.dart
class User {
  final String id;
  final String name;
  // ...
}

// repositories/user_repository.dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUserById(String id);
}

// usecases/get_user_by_id.dart
class GetUserById {
  final UserRepository repository;
  Future<Either<Failure, User>> call(String id) async {
    return await repository.getUserById(id);
  }
}
```

### 2. Data Layer (数据层)
**位置**: `lib/features/[feature_name]/data/`

负责数据获取和存储，实现 Domain 层定义的接口。

- **Data Sources**: 数据源（远程 API、本地数据库）
- **Models**: 数据模型，包含 JSON 序列化/反序列化
- **Repository Implementations**: 仓库接口的具体实现

**示例**:
```dart
// models/user_model.dart
@JsonSerializable()
class UserModel extends User {
  factory UserModel.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}

// datasources/user_remote_datasource.dart
abstract class UserRemoteDataSource {
  Future<UserModel> getUserById(String id);
}

// repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  // 实现接口方法...
}
```

### 3. Presentation Layer (表现层)
**位置**: `lib/features/[feature_name]/presentation/`

负责 UI 展示和用户交互。

- **Bloc/Cubit**: 状态管理
- **Pages**: 页面组件
- **Widgets**: 可复用组件

**示例**:
```dart
// bloc/user_bloc.dart
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserById getUserById;
  // 处理事件...
}

// pages/user_list_page.dart
class UserListPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        // UI 构建...
      },
    );
  }
}
```

## 添加新功能的步骤

### 1. 创建 Domain 层

1. 创建 Entity:
```dart
// lib/features/product/domain/entities/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  // ...
}
```

2. 创建 Repository 接口:
```dart
// lib/features/product/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, Product>> getProductById(String id);
}
```

3. 创建 Use Case:
```dart
// lib/features/product/domain/usecases/get_product_by_id.dart
class GetProductById {
  final ProductRepository repository;
  Future<Either<Failure, Product>> call(String id) async {
    return await repository.getProductById(id);
  }
}
```

### 2. 创建 Data 层

1. 创建 Model:
```dart
// lib/features/product/data/models/product_model.dart
@JsonSerializable()
class ProductModel extends Product {
  factory ProductModel.fromJson(Map<String, dynamic> json) => ...
}
```

2. 创建 Data Sources:
```dart
// lib/features/product/data/datasources/product_remote_datasource.dart
abstract class ProductRemoteDataSource {
  Future<ProductModel> getProductById(String id);
}
```

3. 实现 Repository:
```dart
// lib/features/product/data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  // 实现接口...
}
```

### 3. 创建 Presentation 层

1. 创建 Bloc:
```dart
// lib/features/product/presentation/bloc/product_bloc.dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  // ...
}
```

2. 创建页面:
```dart
// lib/features/product/presentation/pages/product_page.dart
class ProductPage extends StatelessWidget {
  // ...
}
```

## 依赖注入配置

### 使用 Injectable

1. 在类上添加注解:
```dart
@injectable
class GetProductById {
  // ...
}
```

2. 运行代码生成:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. 在 main.dart 中初始化:
```dart
void main() {
  configureDependencies();
  runApp(const MyApp());
}
```

## 错误处理

项目使用 `dartz` 包的 `Either` 类型进行错误处理：

- `Left`: 表示失败（Failure）
- `Right`: 表示成功（数据）

在 Repository 和 Use Case 中统一使用 `Either<Failure, T>` 作为返回值。

## 最佳实践

1. **单一职责**: 每个 Use Case 只做一件事
2. **依赖倒置**: Domain 层定义接口，Data 层实现接口
3. **测试友好**: Domain 层不依赖外部框架，易于单元测试
4. **可维护性**: 清晰的层次结构，便于维护和扩展

