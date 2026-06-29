import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/child_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class ChildSetupScreen extends ConsumerStatefulWidget {
  const ChildSetupScreen({super.key});

  @override
  ConsumerState<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends ConsumerState<ChildSetupScreen> {
  final _nameCtrl = TextEditingController();
  int _selectedLevel = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前を入力してね！')),
      );
      return;
    }

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(childNotifierProvider.notifier).createChild(user.uid, name, _selectedLevel);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('子どものプロフィール設定')),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('👦 名前を入れてね', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: '名前（例：たろう）',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 24),
            const Text('🎯 レベルを選んでね', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [1, 2, 3].map((lv) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _LevelChip(
                    level: lv,
                    isSelected: _selectedLevel == lv,
                    onTap: () => setState(() => _selectedLevel = lv),
                  ),
                ),
              )).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _create,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('ゲームスタート！'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final int level;
  final bool isSelected;
  final VoidCallback onTap;

  static const _colors = [AppColors.level1, AppColors.level2, AppColors.level3];
  static const _labels = ['レベル1\n小1〜3', 'レベル2\n小3〜5', 'レベル3\n小5〜6'];
  static const _stars = ['⭐', '⭐⭐', '⭐⭐⭐'];

  const _LevelChip({required this.level, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _colors[level - 1];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Text(_stars[level - 1], style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              _labels[level - 1],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
