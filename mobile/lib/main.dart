import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:easy_reading/presentation/app.dart';
import 'package:easy_reading/core/firebase/firebase_config.dart';
import 'package:easy_reading/data/services/auth_service.dart';
import 'package:easy_reading/presentation/blocs/auth/auth_bloc.dart';
import 'package:easy_reading/core/bloc/bloc_observer.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    logger.i('Iniciando aplicativo EasyReading...');
    
    // Configura o BLoC observer
    Bloc.observer = AppBlocObserver();
    logger.i('BLoC observer configurado');
    
    // Inicializa o Firebase
    logger.i('Configurando Firebase...');
    await FirebaseConfig.initializeFirebase();
    logger.i('Firebase configurado com sucesso!');
    
    // Cria as instâncias dos serviços
    final authService = AuthService();
    logger.i('Serviços inicializados');
    
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
    logger.i('App iniciado com sucesso!');
  } catch (e, stackTrace) {
    logger.e('Erro ao iniciar o app', e, stackTrace);
    rethrow;
  }
}
