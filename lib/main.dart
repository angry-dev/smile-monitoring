import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
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

class MyApp extends StatelessWidget {
  final String? loginRole;
  const MyApp({super.key, this.loginRole});

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (loginRole == 'admin') {
      home = const AdminHomePage();
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
          title: 'Flutter Demo',
          theme: AppTheme.light,
          home: home,
        );
      },
    );
  }
}
