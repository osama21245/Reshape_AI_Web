import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_cubit.dart';
import 'package:reshapeai/presentation/cubits/transformation/transformation_state.dart';
import 'package:reshapeai/presentation/widgets/gradient_button.dart';
import 'package:reshapeai/presentation/screens/transformations/transformations_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _selectedRoomType = 'living room';
  String _selectedStyle = 'modern';
  String _customization = '';
  bool _isUploading = false;

  final List<String> _roomTypes = [
    'living room',
    'bedroom',
    'kitchen',
    'bathroom',
    'office',
    'dining room',
    'outdoor space',
  ];

  final List<String> _styles = [
    'modern',
    'minimalist',
    'industrial',
    'scandinavian',
    'bohemian',
    'mid-century modern',
    'traditional',
    'rustic',
    'contemporary',
    'art deco',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _uploadImage() {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    context.read<TransformationCubit>().uploadTransformation(
          imageFile: _imageFile!,
          roomType: _selectedRoomType,
          style: _selectedStyle,
          customization: _customization,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Create Transformation',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: BlocListener<TransformationCubit, TransformationState>(
        listener: (context, state) {
          if (state.status == TransformationStatus.success &&
              state.uploadSuccess) {
            setState(() {
              _isUploading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transformation created successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TransformationsScreen()),
            );
          } else if (state.status == TransformationStatus.error) {
            setState(() {
              _isUploading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Failed to create transformation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                SizedBox(height: 24.h),
                _buildRoomTypeSection(),
                SizedBox(height: 24.h),
                _buildStyleSection(),
                SizedBox(height: 24.h),
                _buildCustomizationSection(),
                SizedBox(height: 32.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Photo',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload a photo of the room you want to transform',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
        ),
        SizedBox(height: 16.h),
        if (_imageFile == null)
          GestureDetector(
            onTap: () => _showImageSourceDialog(),
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 60.sp,
                    color: const Color(0xFF8B5CF6),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Tap to upload a photo',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  _imageFile!,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => setState(() => _imageFile = null),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => _showImageSourceDialog(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRoomTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Type',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select the type of room in your photo',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRoomType,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              items: _roomTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRoomType = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Design Style',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Choose a style for your room transformation',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStyle,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              items: _styles.map((String style) {
                return DropdownMenuItem<String>(
                  value: style,
                  child: Text(style),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStyle = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details (Optional)',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Add any specific details or preferences',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _customization = value;
              });
            },
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g., with blue walls and wooden furniture',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              contentPadding: EdgeInsets.all(16.w),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: _isUploading
          ? Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Creating your transformation...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'This may take a minute',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : GradientButton(
              onPressed: _uploadImage,
              text: 'Transform Room',
              width: double.infinity,
            ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30.sp,
              color: const Color(0xFF8B5CF6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
