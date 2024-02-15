import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_example1/common/view/root_tab.dart';
import 'package:riverpod_example1/common/view/splash_screen.dart';
import 'package:riverpod_example1/restaurant/view/basket_screen.dart';
import 'package:riverpod_example1/restaurant/view/restaurant_detail_screen.dart';
import 'package:riverpod_example1/user/model/user_model.dart';
import 'package:riverpod_example1/user/provider/user_me_provider.dart';
import 'package:riverpod_example1/user/view/login_screen.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({required this.ref}) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      // 이전값과 이후값이 다를 때에만 리스너 호출
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          name: RootTab.routeName,
          builder: (_, __) => RootTab(),
          routes: [
            GoRoute(
              path: 'restaurant/:rid',
              name: RestaurantDetailScreen.routeName,
              builder: (_, state) =>
                  RestaurantDetailScreen(id: state.pathParameters['rid']!),
            ),
          ],
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (_, __) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (_, __) => LoginScreen(),
        ),
        GoRoute(
          path: '/basket',
          name: BasketScreen.routeName,
          builder: (_, __) => BasketScreen(),
        ),
      ];

  // 순환참조 해결을 위한 로그아웃 분리
  void logout() {
    ref.read(userMeProvider.notifier).logout();
  }

  // SplashScreen
  // 앱을 처음 시작했을 때
  // 토큰이 존재하는지 확인하고
  // 로그인 스크린으로 보내줄지
  // 홈 스크린으로 보내줄지 확인하는 로직이 필요
  String? redirectLogic(BuildContext context, GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);
    print('redirectLogic has called');
    // 고라우터 체크
    final logginIn = state.uri.toString() == '/login';

    print('logginIn is $logginIn, user is $user');
    // 유저 정보가 없는데
    // 로그인중이면 그대로 로그인 페이지에 두고
    // 만약에 로그인중이 아니라면 로그인 페이지로 이동
    if (user == null) {
      return logginIn ? null : '/login';
    }

    // user가 null이 아님

    // UserModel
    // 사용자 정보가 있는 상태라면
    // 로그인 중이거나 현재 위치가 SplashScreen이면
    // 홈으로 이동
    if (user is UserModel) {
      return logginIn || state.uri.toString() == '/splash' ? '/' : null;
    }

    //UserModelError
    if (user is UserModelError) {
      context.go('/login');
      return !logginIn ? '/login' : null;
    }

    print('test001');
    return null;
  }
}
