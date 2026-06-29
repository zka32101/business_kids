import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/child_provider.dart';
import '../../providers/game_session_provider.dart';
import 'game_tab.dart';
import 'ledger_tab.dart';
import 'profile_tab.dart';
// import 'challenges_tab.dart'; // TODO: Phase 1 - ゲーム性強化

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartDay());
  }

  void _checkAndStartDay() {
    final childAsync = ref.read(currentChildProvider);
    childAsync.whenData((child) {
      if (child == null) {
        context.go('/level-select');
        return;
      }
      if (child.shouldShowBankruptcy) {
        context.go('/bankruptcy');
        return;
      }
      final gameState = ref.read(gameSessionProvider);
      if (gameState.session == null) {
        ref.read(gameSessionProvider.notifier).startDay(child);
      }
    });
  }

  static const _tabs = [
    BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'ゲーム'),
    BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: '帳簿'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'プロフィール'),
  ];

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(currentChildProvider);

    return childAsync.when(
      data: (child) {
        if (child == null) return const SizedBox();
        return Scaffold(
          body: IndexedStack(
            index: _currentTab,
            children: [
              GameTab(child: child),
              LedgerTab(child: child),
              ProfileTab(child: child),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (i) => setState(() => _currentTab = i),
            items: _tabs,
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('エラー: $e')),
      ),
    );
  }
}
