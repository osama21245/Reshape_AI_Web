import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reshapeai/core/theme/app_theme.dart';
import 'package:reshapeai/data/models/transformation_model.dart';
import 'package:reshapeai/presentation/cubits/user/user_cubit.dart';
import 'package:reshapeai/presentation/cubits/user/user_state.dart';
import 'package:reshapeai/presentation/screens/upload/upload_screen.dart';
import 'package:reshapeai/presentation/screens/transformations/transformations_screen.dart';
import 'package:reshapeai/presentation/screens/settings/settings_screen.dart';
import 'package:reshapeai/presentation/screens/billing/billing_screen.dart';
import 'package:reshapeai/presentation/screens/transformation_details/transformation_details_screen.dart';
import 'package:reshapeai/presentation/widgets/gradient_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildHeader(context),
                SizedBox(height: 30.h),
                _buildWelcomeSection(context),
                SizedBox(height: 30.h),
                _buildActionButtons(context),
                SizedBox(height: 30.h),
                _buildRecentTransformations(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.status == UserStatus.loading) {
          return Shimmer.fromColors(
            baseColor: AppTheme.cardBackground,
            highlightColor: AppTheme.borderColor,
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }

        if (state.user != null) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: AppTheme.cardDecoration,
            child: Row(
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
                    radius: 24.r,
                    backgroundColor: AppTheme.cardBackground,
                    backgroundImage: state.user!.profileImage != null
                        ? CachedNetworkImageProvider(state.user!.profileImage!)
                        : null,
                    child: state.user!.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 24.sp,
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
                      'Welcome back,',
                      style: AppTheme.bodyMedium(context),
                    ),
                    Text(
                      state.user!.name,
                      style: AppTheme.headingSmall(context),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BillingScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${state.user!.credits}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: AppTheme.textSecondary,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.2),
            AppTheme.primaryBlue.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
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
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.accentYellow,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'Welcome to Reshape AI',
                style: AppTheme.headingSmall(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            'Transform your living spaces with AI-powered interior design. Upload a photo of your room and see it reimagined in different styles.',
            style: AppTheme.bodyMedium(context).copyWith(
              height: 1.6,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 24.h),
          GradientButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
            },
            text: 'Start Transforming',
            height: 50.h,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'New Transformation',
                    style: AppTheme.headingSmall(context),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Transform your space',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TransformationsScreen(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: AppTheme.primaryBlue,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'My Transformations',
                    style: AppTheme.headingSmall(context),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'View your gallery',
                    style: AppTheme.bodySmall(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransformations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transformations',
              style: AppTheme.headingMedium(context),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TransformationsScreen()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state.status == UserStatus.loading) {
              return _buildLoadingTransformations();
            }

            if (state.transformations.isEmpty) {
              return _buildEmptyTransformations(context);
            }

            final recentTransformations =
                state.transformations.take(3).toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransformations.length,
              itemBuilder: (context, index) {
                final transformation = recentTransformations[index];
                return _buildTransformationItem(context, transformation);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingTransformations() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Shimmer.fromColors(
            baseColor: AppTheme.cardBackground,
            highlightColor: AppTheme.borderColor,
            child: Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTransformations(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.image_outlined,
              size: 48.sp,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'No transformations yet',
              style: AppTheme.headingSmall(context),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start by uploading a photo',
              style: AppTheme.bodyMedium(context),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Upload Photo',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformationItem(
      BuildContext context, TransformationModel transformation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransformationDetailsScreen(
              transformation: transformation,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            children: [
              SizedBox(
                width: 100.w,
                height: 100.h,
                child: CachedNetworkImage(
                  imageUrl: transformation.transformedImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppTheme.cardBackground,
                    highlightColor: AppTheme.borderColor,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.cardBackground,
                    child: Icon(
                      Icons.error_outline,
                      color: AppTheme.textSecondary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          transformation.style,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Room Transformation',
                        style: AppTheme.headingSmall(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Created ${_formatDate(transformation.createdAt)}',
                        style: AppTheme.bodySmall(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          backgroundColor: AppTheme.cardBackground,
          selectedItemColor: AppTheme.primaryPurple,
          unselectedItemColor: AppTheme.textSecondary,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.sp,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24.sp),
              activeIcon: Icon(Icons.home, size: 24.sp),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_photo_alternate_outlined, size: 24.sp),
              activeIcon: Icon(Icons.add_photo_alternate, size: 24.sp),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined, size: 24.sp),
              activeIcon: Icon(Icons.grid_view, size: 24.sp),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 24.sp),
              activeIcon: Icon(Icons.settings, size: 24.sp),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on home
                break;
              case 1:
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                );
                break;
              case 2:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TransformationsScreen(),
                  ),
                );
                break;
              case 3:
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}
