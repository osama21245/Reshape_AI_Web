import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:reshapeai/presentation/screens/auth/qr_scan/qr_scan_test_screen.dart';
import 'package:reshapeai/presentation/screens/home/home_screen.dart';

import '../../cubits/user/user_cubit.dart';
import '../../cubits/user/user_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Check auth status after animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final userCubit = BlocProvider.of<UserCubit>(context, listen: false);
        userCubit.getUserDetails();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state.status == UserStatus.loaded) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state.status == UserStatus.error) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const QrScanTestScreen()),
            );
          }
        },
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.home_work_outlined,
                      size: 60.w,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Reshape AI',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                      ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Transform your space with AI',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
