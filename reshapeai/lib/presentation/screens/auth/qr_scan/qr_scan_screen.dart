import 'dart:io';
import 'dart:convert';
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
                              controller?.toggleFlash();
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
                                    errorMessage = '';
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
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;

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
        if (errorMessage.isNotEmpty)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GradientButton(
                      onPressed: () {
                        setState(() {
                          errorMessage = '';
                        });
                        controller?.resumeCamera();
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
                  _processScannedCode(scannedCode!);
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
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (isScanning && scanData.code != null && !isProcessing) {
        setState(() {
          isScanning = false;
          scannedCode = scanData.code;
        });
        controller.pauseCamera();
        _processScannedCode(scanData.code!);
      }
    });
  }

  void _processScannedCode(String code) {
    try {
      setState(() {
        isProcessing = true;
      });

      // Parse the JSON data from the QR code
      final jsonData = jsonDecode(code);

      // Extract the token from the parsed JSON
      final token = jsonData['token'];
      final expiresAt = jsonData['expiresAt'];

      if (token != null && expiresAt != null) {
        context.read<AuthCubit>().scanQrCode(token, expiresAt);
      } else {
        _handleScanError('Invalid QR code: missing token or expiration');
      }
    } catch (e) {
      _handleScanError('Invalid QR code format');
    }
  }

  void _handleScanError(String message) {
    setState(() {
      errorMessage = message;
      isProcessing = false;
      isScanning = true;
    });
    controller?.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (mounted) {
      setState(() {
        hasPermission = p;
        if (!p) {
          errorMessage = 'Camera permission not granted';
        }
      });
    }

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
