import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/auth/auth_cubit.dart';
import '../../../cubits/auth/auth_state.dart';
import '../../home/home_screen.dart';

class QrScanTestScreen extends StatefulWidget {
  const QrScanTestScreen({super.key});

  @override
  State<QrScanTestScreen> createState() => _QrScanTestScreenState();
}

class _QrScanTestScreenState extends State<QrScanTestScreen> {
  @override
  void initState() {
    context.read<AuthCubit>().scanQrCode(
        "5267731bb51c024da5f643484dfb83e86f3cee9e955c6f31f8ca8957c5471a67",
        "2025-03-11T13:14:30.052Z");
    super.initState();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Scaffold(
          body: Center(
            child: Text('QR Scan Test Screen'),
          ),
        ));
  }
}
