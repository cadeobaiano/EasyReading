import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/home_tab.dart';
import '../decks/decks_tab.dart';
import '../profile/profile_tab.dart';
import '../../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Widget> _tabs = const [
    HomeTab(),
    DecksTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      // Feedback tátil ao trocar de aba
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Conteúdo principal com animação de fade
            AnimatedSwitcher(
              duration: AppTheme.mediumAnimation,
              child: _tabs[_currentIndex],
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
            // Barra de navegação personalizada
            Positioned(
              left: AppTheme.spacing['md']!,
              right: AppTheme.spacing['md']!,
              bottom: AppTheme.spacing['md']!,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                      _tabController.animateTo(index);
                    });
                    HapticFeedback.selectionClick();
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: 'Início',
                      tooltip: 'Tela inicial com seu progresso',
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.library_books_outlined),
                      selectedIcon: const Icon(Icons.library_books),
                      label: 'Decks',
                      tooltip: 'Gerenciar seus decks de flashcards',
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: const Icon(Icons.person),
                      label: 'Perfil',
                      tooltip: 'Configurações e estatísticas',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
