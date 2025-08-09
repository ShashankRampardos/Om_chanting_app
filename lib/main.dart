import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om/screens/tabs.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 64, 204, 255),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);
void main() => runApp(
  ProviderScope(
    child: MaterialApp(theme: theme, home: TabsScreen()),
  ),
);
