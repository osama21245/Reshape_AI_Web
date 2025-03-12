import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reshapeai/core/theme/app_theme.dart';
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
  late Animation<double> _scaleAnimation;

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
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
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
      backgroundColor: AppTheme.darkBackground,
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(70.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(70.r),
                        child: Image.asset(
                          'assets/images/public/app_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Reshape AI',
                      style: AppTheme.gradientText(context, fontSize: 32.sp),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Transform your space with AI',
                      style: AppTheme.bodyMedium(context).copyWith(
                        fontSize: 16.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryPurple,
                        ),
                        strokeWidth: 3.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
