import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/presentation/main_shell.dart';

class SonarVaultApp extends StatelessWidget {
  const SonarVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sona',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
