import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_demo/features/user/domain/entities/user.dart';
import 'package:flutter_demo/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_demo/features/user/domain/usecases/get_user_by_id.dart';
import 'package:flutter_demo/core/error/failures.dart';

@GenerateMocks([UserRepository])
import 'get_user_by_id_test.mocks.dart';

void main() {
  late GetUserById useCase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    useCase = GetUserById(mockUserRepository);
  });

  const testUserId = '1';
  const testUser = User(
    id: testUserId,
    name: '测试用户',
    email: 'test@example.com',
  );

  test('应该从仓库获取用户', () async {
    // arrange
    when(mockUserRepository.getUserById(testUserId))
        .thenAnswer((_) async => const Right(testUser));

    // act
    final result = await useCase(testUserId);

    // assert
    expect(result, const Right(testUser));
    verify(mockUserRepository.getUserById(testUserId));
    verifyNoMoreInteractions(mockUserRepository);
  });

  test('当仓库返回失败时应该返回失败', () async {
    // arrange
    when(mockUserRepository.getUserById(testUserId))
        .thenAnswer((_) async => const Left(ServerFailure('服务器错误')));

    // act
    final result = await useCase(testUserId);

    // assert
    expect(result, const Left(ServerFailure('服务器错误')));
    verify(mockUserRepository.getUserById(testUserId));
    verifyNoMoreInteractions(mockUserRepository);
  });
}

