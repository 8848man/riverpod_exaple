import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_example1/common/const/data.dart';
import 'package:riverpod_example1/common/secure_storage/secure_storage.dart';
import 'package:riverpod_example1/user/provider/auth_provider.dart';

// SecureStorage, interceptor를 사용한 dio 인스턴스를 일관되게 제공하는 Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(CustomInterceptor(storage: storage, ref: ref));

  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;
  CustomInterceptor({
    required this.storage,
    required this.ref,
  });

  // 1) 요청을 보낼 때
  /// 요청이 보내질 때마다
  /// 만약에 요청의 Header에 accessToken : true라는 값이 있다면
  /// 실제 토큰을 가져와서 (storage에서) authorization : bearer $token으로 헤더를 변경한다.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO: implement onRequest
    print('[REQ] [${options.method}] ${options.uri}');

    // restaurant_repository에 있는 @header
    if (options.headers['accessToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);
      // 실제 토큰으로 대체
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    if (options.headers['refreshToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('refreshToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);
      // 실제 토큰으로 대체
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을 때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');
    // TODO: implement onResponse
    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을 때
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 401 에러가 났을 때 (status code)
    // 토큰을 재발급 받는 시도를 하고, 토큰이 재발급되면
    // 다시 새로운 토큰으로 요청을 한다.
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refeshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 아예 없으면
    // 당연히 에러를 던진다
    if (refeshToken == null) {
      // 에러를 던질 때에는 handler.reject를 사용한다.
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    // 토큰 refresh가 필요할 경우 로직
    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        final resp = await dio.post(
          'http://$ip/auth/token',
          options: Options(
            headers: {'authorization': 'Bearer $refeshToken'},
          ),
        );

        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions;

        // 토큰 변경하기
        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        // 요청 재전송
        final response = await dio.fetch(options);

        return handler.resolve(response);
      } on DioError catch (e) {
        ref.read(authProvider.notifier).logout();

        return handler.reject(e);
      }
    }

    super.onError(err, handler);
  }
}
