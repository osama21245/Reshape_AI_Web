import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_cubit.dart';
import 'package:reshapeai/presentation/cubits/auth/auth_state.dart';
import 'package:reshapeai/presentation/screens/home/home_screen.dart';
import 'package:reshapeai/presentation/widgets/gradient_button.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  String? scannedCode;
  bool isProcessing = false;
  bool hasPermission = false;
  bool cameraInitialized = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
      if (!hasPermission) {
        errorMessage = 'Camera permission is required to scan QR codes';
      }
    });
  }

  // To ensure hot reload works with the QR scanner
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state.status == AuthStatus.error) {
          setState(() {
            isProcessing = false;
            isScanning = true;
            scannedCode = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );

          // Resume scanning
          controller?.resumeCamera();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Scan QR Code',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                'Scan the QR code from the website to log in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: !hasPermission
                  ? _buildPermissionError()
                  : isScanning
                      ? _buildQrView(context)
                      : _buildScannedResult(context),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: !hasPermission
                    ? GradientButton(
                        onPressed: () async {
                          await _checkPermission();
                        },
                        text: 'Grant Permission',
                        width: 200.w,
                      )
                    : isScanning
                        ? GradientButton(
                            onPressed: () {
                              if (controller != null) {
                                controller!.toggleFlash();
                              }
                            },
                            text: 'Toggle Flash',
                            width: 200.w,
                          )
                        : isProcessing
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF8B5CF6)),
                              )
                            : GradientButton(
                                onPressed: () {
                                  setState(() {
                                    isScanning = true;
                                    scannedCode = null;
                                  });
                                  controller?.resumeCamera();
                                },
                                text: 'Scan Again',
                                width: 200.w,
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography,
              size: 80.sp,
              color: Colors.red,
            ),
            SizedBox(height: 20.h),
            Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Please grant camera permission to scan QR codes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;

    // Handle camera initialization errors
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: const Color(0xFF8B5CF6),
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: scanArea,
          ),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        if (!cameraInitialized)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF8B5CF6),
                ),
              ),
            ),
          ),
        if (errorMessage.isNotEmpty)
          Container(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Camera Error',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GradientButton(
                      onPressed: () {
                        setState(() {
                          errorMessage = '';
                          isScanning = true;
                        });
                        _initializeCamera();
                      },
                      text: 'Try Again',
                      width: 200.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _initializeCamera() {
    try {
      if (controller != null) {
        controller!.resumeCamera();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Widget _buildScannedResult(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 80.sp,
            color: const Color(0xFF8B5CF6),
          ),
          SizedBox(height: 20.h),
          Text(
            'QR Code Scanned',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Authenticating...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 30.h),
          if (!isProcessing)
            GradientButton(
              onPressed: () {
                if (scannedCode != null) {
                  setState(() {
                    isProcessing = true;
                  });
                  context.read<AuthCubit>().scanQrCode(scannedCode!);
                }
              },
              text: 'Authenticate',
              width: 200.w,
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      cameraInitialized = true;
    });

    try {
      controller.scannedDataStream.listen((scanData) {
        print('scanData: ${scanData.code.toString()}');
        if (isScanning && scanData.code != null) {
          setState(() {
            isScanning = false;
            scannedCode = scanData.code;
          });
          controller.pauseCamera();

          // Auto authenticate
          setState(() {
            isProcessing = true;
          });
          context.read<AuthCubit>().scanQrCode(scanData.code!);
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error scanning QR code: $e';
      });
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    setState(() {
      hasPermission = p;
      if (!p) {
        errorMessage = 'Camera permission not granted';
      }
    });

    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission not granted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
