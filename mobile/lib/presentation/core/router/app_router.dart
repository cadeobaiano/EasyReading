import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_reading/presentation/features/main/main_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeTab(),
            routes: [
              // Rotas aninhadas da Home
            ],
          ),
          GoRoute(
            path: '/decks',
            builder: (context, state) => const DecksTab(),
            routes: [
              // Rotas aninhadas dos Decks
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileTab(),
            routes: [
              // Rotas aninhadas do Perfil
            ],
          ),
        ],
      ),
    ],
  );
}
