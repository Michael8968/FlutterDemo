import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel?> getUserById(String id);
  Future<List<UserModel>> getAllUsers();
  Future<void> cacheUser(UserModel user);
  Future<void> cacheUsers(List<UserModel> users);
  Future<void> deleteUser(String id);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  // 这里应该注入本地存储（如 SharedPreferences 或 Hive）
  // final SharedPreferences sharedPreferences;

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      // 实际项目中这里会从本地存储读取
      // final jsonString = sharedPreferences.getString('user_$id');
      // if (jsonString != null) {
      //   return UserModel.fromJson(jsonDecode(jsonString));
      // }
      return null;
    } catch (e) {
      throw CacheException('获取本地用户失败: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      // 实际项目中这里会从本地存储读取
      // final jsonString = sharedPreferences.getString('users');
      // if (jsonString != null) {
      //   final List<dynamic> jsonList = jsonDecode(jsonString);
      //   return jsonList.map((json) => UserModel.fromJson(json)).toList();
      // }
      return [];
    } catch (e) {
      throw CacheException('获取本地用户列表失败: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      // 实际项目中这里会保存到本地存储
      // await sharedPreferences.setString(
      //   'user_${user.id}',
      //   jsonEncode(user.toJson()),
      // );
    } catch (e) {
      throw CacheException('缓存用户失败: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    try {
      // 实际项目中这里会保存到本地存储
      // final jsonList = users.map((user) => user.toJson()).toList();
      // await sharedPreferences.setString('users', jsonEncode(jsonList));
    } catch (e) {
      throw CacheException('缓存用户列表失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      // 实际项目中这里会从本地存储删除
      // await sharedPreferences.remove('user_$id');
    } catch (e) {
      throw CacheException('删除本地用户失败: ${e.toString()}');
    }
  }
}

