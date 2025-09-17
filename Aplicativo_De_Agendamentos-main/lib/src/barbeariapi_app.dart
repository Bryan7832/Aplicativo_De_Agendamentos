import 'package:pi2/src/core/ui/barbeariapi_nav_global_key.dart';
import 'package:pi2/src/core/ui/barbeariapi_theme.dart';
import 'package:pi2/src/features/auth/login/login_page.dart';
import 'package:pi2/src/features/auth/register/barbeariapi/barbeariapi_register_page.dart';
import 'package:pi2/src/features/auth/register/user/user_register_page.dart';
import 'package:pi2/src/features/employee/register/employee_register_page.dart';
import 'package:pi2/src/features/employee/schedule/employee_schedule_page.dart';
import 'package:pi2/src/features/home/adm/home_adm_page.dart';
import 'package:pi2/src/features/home/employee/home_employee_page.dart';
import 'package:pi2/src/features/schedule/schedule_page.dart';
import 'package:pi2/src/features/splash/splash_page.dart';
import 'package:pi2/src/features/user/edit/user_edit_page.dart'; // Adicione esta importação
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:asyncstate/asyncstate.dart';

class BarbeariapiApp extends StatelessWidget {
  const BarbeariapiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncStateBuilder(
      builder: (asyncNavigatorObserver) {
        return MaterialApp(
          navigatorObservers: [asyncNavigatorObserver],
          navigatorKey: BarbeariapiNavGlobalKey.instance.navKey,
          theme: BarbeariapiTheme.themeData,
          title: 'Barbeariapi',
          home: const SplashPage(),
          routes: {
            '/auth/login': (_) => const LoginPage(),
            '/auth/register/user': (_) => const UserRegisterPage(),
            '/auth/register/barbeariapi':
                (_) => const BarbeariapiRegisterPage(),
            '/home/adm': (_) => const HomeADMPage(),
            '/home/employee': (_) => const HomeEmployeePage(),
            '/employee/register': (_) => const EmployeeRegisterPage(),
            '/employee/schedule': (_) => const EmployeeSchedulePage(),
            '/schedule': (_) => const SchedulePage(),
            '/user/edit': (_) => const UserEditPage(), // Nova rota para edição
          },
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
