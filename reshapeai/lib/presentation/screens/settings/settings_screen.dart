import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_cubit.dart';
import 'package:reshapeai/presentation/cubits/user/user_cubit.dart';
import 'package:reshapeai/presentation/cubits/user/user_state.dart';
import 'package:reshapeai/presentation/screens/auth/qr_scan/qr_scan_screen.dart';
import 'package:reshapeai/presentation/widgets/gradient_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state.status == UserStatus.loading) {
            return _buildLoadingState();
          } else if (state.status == UserStatus.loaded && state.user != null) {
            return _buildSettingsContent(context, state);
          } else {
            return _buildErrorState();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 24.h,
              width: 150.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 16.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 32.h),
            ...List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Container(
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: Colors.red[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please try again later',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, UserState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(context, state),
          SizedBox(height: 24.h),
          _buildSettingsSection(context),
          SizedBox(height: 24.h),
          _buildAboutSection(context),
          SizedBox(height: 32.h),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserState state) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[800]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: state.user!.profileImage != null
                        ? CachedNetworkImageProvider(state.user!.profileImage!)
                        : null,
                    child: state.user!.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 50.sp,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 36.w,
                          minHeight: 36.h,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          // TODO: Implement profile picture update
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              state.user!.name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              state.user!.email,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () {
                // TODO: Implement edit profile
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // TODO: Implement notifications settings
                },
              ),
              Divider(color: Colors.grey[800], height: 1),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Privacy',
                onTap: () {
                  // TODO: Implement privacy settings
                },
              ),
              Divider(color: Colors.grey[800], height: 1),
              _buildSettingItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // TODO: Implement language settings
                },
              ),
              Divider(color: Colors.grey[800], height: 1),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Dark',
                onTap: () {
                  // TODO: Implement theme settings
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.info_outline,
                title: 'About Reshape AI',
                onTap: () {
                  // TODO: Implement about page
                },
              ),
              Divider(color: Colors.grey[800], height: 1),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Implement help & support
                },
              ),
              Divider(color: Colors.grey[800], height: 1),
              _buildSettingItem(
                icon: Icons.policy_outlined,
                title: 'Terms & Privacy Policy',
                onTap: () {
                  // TODO: Implement terms & privacy policy
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: Colors.grey[400],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24.sp,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GradientButton(
      onPressed: () {
        context.read<AuthCubit>().logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const QrScanScreen()),
          (route) => false,
        );
      },
      text: 'Logout',
    );
  }
}
