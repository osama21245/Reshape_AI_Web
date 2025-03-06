import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reshapeai/domain/entities/transformation.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_cubit.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_state.dart';
import 'package:reshapeai/presentation/widgets/gradient_button.dart';
import 'package:reshapeai/presentation/screens/upload/upload_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class TransformationsScreen extends StatefulWidget {
  const TransformationsScreen({Key? key}) : super(key: key);

  @override
  State<TransformationsScreen> createState() => _TransformationsScreenState();
}

class _TransformationsScreenState extends State<TransformationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransformationCubit>().fetchTransformations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'My Transformations',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<TransformationCubit, TransformationState>(
        builder: (context, state) {
          if (state.status == TransformationStatus.loading) {
            return _buildLoadingState();
          } else if (state.status == TransformationStatus.loaded) {
            if (state.transformations.isEmpty) {
              return _buildEmptyState();
            }
            return _buildTransformationsList(state.transformations);
          } else if (state.status == TransformationStatus.error) {
            return _buildErrorState(state.error);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 80.sp,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16.h),
          Text(
            'No transformations yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload a photo to start transforming',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
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
            'Something went wrong',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error ?? 'Failed to load transformations',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationsList(List<Transformation> transformations) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: transformations.length,
      itemBuilder: (context, index) {
        final transformation = transformations[index];
        return _buildTransformationCard(transformation);
      },
    );
  }

  Widget _buildTransformationCard(Transformation transformation) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTransformationImage(
                    transformation.originalImageUrl,
                    'Original',
                  ),
                ),
                Expanded(
                  child: _buildTransformationImage(
                    transformation.transformedImageUrl,
                    'Transformed',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transformation.style,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a')
                      .format(transformation.createdAt),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationImage(String imageUrl, String label) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: Container(color: Colors.white),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[800],
              child: Icon(
                Icons.broken_image,
                color: Colors.grey[600],
                size: 40.sp,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8.h,
          left: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
