import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reshapeai/firebase_options.dart';
import 'package:reshapeai/core/di/service_locator.dart';
import 'package:reshapeai/core/theme/app_theme.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_cubit.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_cubit.dart';
import 'package:reshapeai/presentation/cubits/user/user_cubit.dart';
import 'package:reshapeai/presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize service locator
  await setupServiceLocator();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  AppTheme.setSystemUIOverlayStyle();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<UserCubit>(create: (_) => sl<UserCubit>()),
        BlocProvider<TransformationCubit>(
            create: (_) => sl<TransformationCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'ReshapeAI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
