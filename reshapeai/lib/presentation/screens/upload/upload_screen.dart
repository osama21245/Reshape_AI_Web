import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reshapeai/presentation/widgets/gradient_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Upload Image',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select an image to transform',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: _selectedImage == null
                    ? _buildImagePlaceholder()
                    : _buildSelectedImage(),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      text: 'Take Photo',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GradientButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      text: 'Choose from Gallery',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (_selectedImage != null)
                GradientButton(
                  onPressed: () {
                    // Continue to next step
                    // This would be implemented in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing image...')),
                    );
                  },
                  text: 'Continue',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 80.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16.h),
            Text(
              'No image selected',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the buttons below to select an image',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
