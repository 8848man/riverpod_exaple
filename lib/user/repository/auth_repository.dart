import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_example1/common/const/data.dart';
import 'package:riverpod_example1/common/dio/dio.dart';
import 'package:riverpod_example1/common/model/login_response.dart';
import 'package:riverpod_example1/common/model/token_response.dart';
import 'package:riverpod_example1/common/utils/data_utils.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return AuthRepository(dio: dio, baseUrl: 'http://$ip/auth');
});

class AuthRepository {
  // http://$ip/auth
  final String baseUrl;
  final Dio dio;

  AuthRepository({
    required this.baseUrl,
    required this.dio,
  });

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final serialized = DataUtils.plainToBase64('$username:$password');

    final resp = await dio.post(
      '$baseUrl/login',
      options: Options(
        headers: {
          'authorization': 'Basic $serialized',
        },
      ),
    );

    return LoginResponse.fromJson(resp.data);
  }

  Future<TokenResponse> token() async {
    final resp = await dio.post(
      '$baseUrl/token',
      options: Options(
        headers: {
          // Login과 Token Refresh Repository 7:00에서
          // 헤더 변환을 자동으로 해준다고 해서 바꿈. 어떻게? dio 인터셉터 코드 확인
          // 'authorization': 'Bearer $token',
          'refreshToken': 'true',
        },
      ),
    );

    return TokenResponse.fromJson(resp.data);
  }
}
