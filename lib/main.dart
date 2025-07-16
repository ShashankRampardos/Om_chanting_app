import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om/screens/tabs.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 254, 135, 23),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);
void main() => runApp(MaterialApp(theme: theme, home: TabsScreen()));
