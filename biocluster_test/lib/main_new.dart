import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'app_theme.dart';

void main() {
  runApp(const BioClusterApp());
}

class BioClusterApp extends StatelessWidget {
  const BioClusterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioCluster Tool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
