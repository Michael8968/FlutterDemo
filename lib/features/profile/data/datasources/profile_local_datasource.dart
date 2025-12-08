import 'package:hive/hive.dart';
import '../models/user_profile_model.dart';

/// 用户档案本地数据源抽象
abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getProfile();
  Future<UserProfileModel> saveProfile(UserProfileModel profile);
  Future<void> deleteProfile();
}

/// 用户档案本地数据源实现
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _boxName = 'profile_box';
  static const String _profileKey = 'user_profile';

  Future<Box<UserProfileModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<UserProfileModel>(_boxName);
    }
    return Hive.box<UserProfileModel>(_boxName);
  }

  @override
  Future<UserProfileModel?> getProfile() async {
    final box = await _getBox();
    return box.get(_profileKey);
  }

  @override
  Future<UserProfileModel> saveProfile(UserProfileModel profile) async {
    final box = await _getBox();
    await box.put(_profileKey, profile);
    return profile;
  }

  @override
  Future<void> deleteProfile() async {
    final box = await _getBox();
    await box.delete(_profileKey);
  }
}
