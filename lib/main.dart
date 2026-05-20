import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:om/screens/auth/login.dart';
import 'package:om/screens/tabs.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 64, 204, 255),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() {
  debugPrint('debugPrint');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const CheckAuthScreen(),
    );
  }
}

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    String? token = await storage.read(key: "jwt_token");

    print("TOKEN: $token");

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    /// NO TOKEN
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      return;
    }

    /// CHECK JWT EXPIRY
    bool isExpired = JwtDecoder.isExpired(token);

    print("TOKEN EXPIRED: $isExpired");

    /// TOKEN EXPIRED
    if (isExpired) {
      await storage.delete(key: "jwt_token");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      return;
    }

    /// TOKEN VALID
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TabsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020B25),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFE7C08D))),
    );
  }
}
