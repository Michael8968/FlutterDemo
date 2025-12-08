import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserById(String id);
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> createUser(UserModel user);
  Future<void> deleteUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  // 这里应该注入 ApiClient
  // final ApiClient apiClient;

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      // 实际项目中这里会调用 API
      // final response = await apiClient.dio.get('/users/$id');
      // return UserModel.fromJson(response.data);
      
      // 示例数据
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(
        id: id,
        name: '示例用户',
        email: 'example@example.com',
      );
    } catch (e) {
      throw ServerException('获取用户失败: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      // 实际项目中这里会调用 API
      // final response = await apiClient.dio.get('/users');
      // return (response.data as List)
      //     .map((json) => UserModel.fromJson(json))
      //     .toList();
      
      // 示例数据
      await Future.delayed(const Duration(seconds: 1));
      return [
        const UserModel(
          id: '1',
          name: '用户1',
          email: 'user1@example.com',
        ),
        const UserModel(
          id: '2',
          name: '用户2',
          email: 'user2@example.com',
        ),
      ];
    } catch (e) {
      throw ServerException('获取用户列表失败: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      // 实际项目中这里会调用 API
      // final response = await apiClient.dio.post('/users', data: user.toJson());
      // return UserModel.fromJson(response.data);
      
      await Future.delayed(const Duration(seconds: 1));
      return user;
    } catch (e) {
      throw ServerException('创建用户失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      // 实际项目中这里会调用 API
      // await apiClient.dio.delete('/users/$id');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw ServerException('删除用户失败: ${e.toString()}');
    }
  }
}

