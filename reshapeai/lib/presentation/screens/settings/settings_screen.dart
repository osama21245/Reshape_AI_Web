import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reshapeai/core/theme/app_theme.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_cubit.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_state.dart';
import 'package:reshapeai/presentation/cubits/user/user_cubit.dart';
import 'package:reshapeai/presentation/cubits/user/user_state.dart';
import 'package:reshapeai/presentation/screens/auth/qr_scan/qr_scan_test_screen.dart';
import 'package:reshapeai/presentation/screens/billing/billing_screen.dart';
import 'package:reshapeai/presentation/widgets/gradient_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTheme.headingMedium(context),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildUserProfile(context),
                SizedBox(height: 30.h),
                _buildCreditsSection(context),
                SizedBox(height: 30.h),
                _buildLogoutButton(context),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.user == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: AppTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundColor: AppTheme.cardBackground,
                      backgroundImage: state.user!.profileImage != null
                          ? NetworkImage(state.user!.profileImage!)
                          : null,
                      child: state.user!.profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 30.sp,
                              color: AppTheme.textSecondary,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user!.name,
                        style: AppTheme.headingSmall(context),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        state.user!.email,
                        style: AppTheme.bodyMedium(context),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              const Divider(color: AppTheme.borderColor),
              SizedBox(height: 20.h),
              Text(
                'Account Information',
                style: AppTheme.headingSmall(context),
              ),
              SizedBox(height: 16.h),
              _buildInfoRow(context, 'Name', state.user!.name),
              SizedBox(height: 12.h),
              _buildInfoRow(context, 'Email', state.user!.email),
              SizedBox(height: 12.h),
              _buildInfoRow(
                  context, 'Member Since', _formatDate(state.user!.createdAt)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium(context),
        ),
        Text(
          value,
          style: AppTheme.bodyLarge(context),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildCreditsSection(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.user == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withOpacity(0.2),
                AppTheme.primaryBlue.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.bolt,
                      color: AppTheme.primaryPurple,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Credits',
                        style: AppTheme.headingSmall(context),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${state.user!.credits} credits remaining',
                        style: AppTheme.bodyMedium(context),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'Use credits to transform your room photos with AI. Each transformation costs 1 credit.',
                style: AppTheme.bodyMedium(context),
              ),
              SizedBox(height: 16.h),
              GradientButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BillingScreen(),
                    ),
                  );
                },
                text: 'Purchase Credits',
                icon: Icons.shopping_cart,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Settings',
            style: AppTheme.headingSmall(context),
          ),
          SizedBox(height: 16.h),
          _buildSettingItem(
            context,
            'Mobile App Login',
            'Scan QR code to login on mobile',
            Icons.qr_code,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QrScanTestScreen(),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          _buildSettingItem(
            context,
            'Notifications',
            'Manage notification settings',
            Icons.notifications_outlined,
            () {
              // Navigate to notifications settings
            },
          ),
          SizedBox(height: 12.h),
          _buildSettingItem(
            context,
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip_outlined,
            () {
              // Navigate to privacy policy
            },
          ),
          SizedBox(height: 12.h),
          _buildSettingItem(
            context,
            'Terms of Service',
            'Read our terms of service',
            Icons.description_outlined,
            () {
              // Navigate to terms of service
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryPurple,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge(context),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall(context),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const QrScanTestScreen()),
            (route) => false,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logout',
              style: AppTheme.headingSmall(context),
            ),
            SizedBox(height: 8.h),
            Text(
              'You will be logged out from this device',
              style: AppTheme.bodyMedium(context),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.cardBackground,
                    title: Text(
                      'Confirm Logout',
                      style: AppTheme.headingSmall(context),
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
                      style: AppTheme.bodyMedium(context),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<UserCubit>().logOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout),
                  SizedBox(width: 8.w),
                  const Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
