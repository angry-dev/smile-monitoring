import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/page/worker_reg_page.dart';
import 'package:flutter_app/provider/customers_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constant/app_prefs.dart';
import 'constant/app_theme.dart';
import 'page/admin_home_page.dart';
import 'page/login_page.dart';
import 'page/user_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final loginRole = await AppPrefs.getLoginRole();
  runApp(ProviderScope(child: MyApp(loginRole: loginRole)));
}

class MyApp extends ConsumerWidget {
  final String? loginRole;
  const MyApp({super.key, this.loginRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget home;
    if (loginRole == 'admin') {
      // 자동로그인 시 adminCodeProvider 세팅
      AppPrefs.getAdminCode().then((code) {
        if (code != null) {
          ref.read(adminCodeProvider.notifier).state = code;
        }
      });
      home = const AdminHomeNavWrapper();
    } else if (loginRole == 'user') {
      home = const UserListPage();
    } else {
      home = const LoginPage();
    }
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: home,
        );
      },
    );
  }
}

class AdminHomeNavWrapper extends ConsumerWidget {
  const AdminHomeNavWrapper({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminCode = ref.watch(adminCodeProvider);
    return FutureBuilder<String?>(
      future: AppPrefs.getAdminCode(),
      builder: (context, snapshot) {
        final autoLoginAdminCode = snapshot.data;
        // adminCodeProvider 또는 AppPrefs.getAdminCode() 값이 'admin'이면 네비게이션 바 표시
        if (adminCode == 'admin' || autoLoginAdminCode == 'admin') {
          return const AdminHomeWithNav();
        } else {
          return const AdminHomePage();
        }
      },
    );
  }
}

class AdminHomeWithNav extends ConsumerStatefulWidget {
  const AdminHomeWithNav({super.key});
  @override
  ConsumerState<AdminHomeWithNav> createState() => _AdminHomeWithNavState();
}

class _AdminHomeWithNavState extends ConsumerState<AdminHomeWithNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? const AdminHomePage() : const WorkerRegPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '나의고객',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '직원관리',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
      ),
    );
  }
}
