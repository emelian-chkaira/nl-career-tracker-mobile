import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_wrapper.dart';
import 'app/features/auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/styles/style.dart';
import 'core/styles/theme_controller.dart';
import 'core/utils/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Dependencies.register();
  await ThemeController.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider<AppWrapperCubit>.value(
        value: getIt<AppWrapperCubit>()..appStarted(),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.instance,
          builder: (_, mode, _) => MaterialApp(
            title: 'NL Career Tracker',
            debugShowCheckedModeBanner: false,
            theme: appTheme(),
            darkTheme: appTheme(Brightness.dark),
            themeMode: mode,
            home: const AppWrapper(),
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      );
}
