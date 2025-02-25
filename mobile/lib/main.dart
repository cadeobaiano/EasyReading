import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/presentation/app.dart';
import 'package:easy_reading/core/firebase/firebase_config.dart';
import 'package:easy_reading/data/services/auth_service.dart';
import 'package:easy_reading/presentation/blocs/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase
  await FirebaseConfig.initializeFirebase();
  
  // Cria as instâncias dos serviços
  final authService = AuthService();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: authService,
          )..add(const AuthCheckRequested()),
        ),
      ],
      child: const EasyReadingApp(),
    ),
  );
}
