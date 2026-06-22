import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';

final _tabIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _tabs = [HomeScreen(), ProgressScreen()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_tabIndexProvider);

    return Scaffold(
      body: IndexedStack(index: index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(_tabIndexProvider.notifier).state = i,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.green.withAlpha(40),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.navy),
            label: 'Treino',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.navy),
            label: 'Evolução',
          ),
        ],
      ),
    );
  }
}
