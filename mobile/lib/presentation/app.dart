import 'package:flutter/material.dart';
import 'package:easy_reading/presentation/core/theme/app_theme.dart';
import 'package:easy_reading/presentation/core/router/app_router.dart';

class EasyReadingApp extends StatelessWidget {
  const EasyReadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Easy Reading',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
