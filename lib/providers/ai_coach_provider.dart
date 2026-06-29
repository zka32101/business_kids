import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/child.dart';
import '../models/game_session.dart';
import '../services/claude_api_service.dart';

const _storage = FlutterSecureStorage();

final claudeApiServiceProvider = FutureProvider<ClaudeApiService?>((ref) async {
  final key = await _storage.read(key: 'claude_api_key');
  if (key == null || key.isEmpty) return null;
  return ClaudeApiService(key);
});

class AiCoachState {
  final String? advice;
  final bool isLoading;
  final String? error;
  final DateTime? lastAdviceAt;

  const AiCoachState({
    this.advice,
    this.isLoading = false,
    this.error,
    this.lastAdviceAt,
  });

  bool get canGetAdviceToday {
    if (lastAdviceAt == null) return true;
    final now = DateTime.now();
    return lastAdviceAt!.day != now.day ||
        lastAdviceAt!.month != now.month ||
        lastAdviceAt!.year != now.year;
  }

  AiCoachState copyWith({String? advice, bool? isLoading, String? error, DateTime? lastAdviceAt}) =>
      AiCoachState(
        advice: advice ?? this.advice,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        lastAdviceAt: lastAdviceAt ?? this.lastAdviceAt,
      );
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final Ref _ref;

  AiCoachNotifier(this._ref) : super(const AiCoachState());

  Future<void> fetchAdvice(ChildModel child, GameSessionModel session) async {
    if (!state.canGetAdviceToday) return;

    state = state.copyWith(isLoading: true);
    try {
      final service = await _ref.read(claudeApiServiceProvider.future);
      if (service == null) {
        state = state.copyWith(
          isLoading: false,
          advice: '今日もよく頑張ったね！明日もがんばろう！',
        );
        return;
      }
      final advice = await service.getCoachAdvice(child, session);
      state = state.copyWith(
        advice: advice,
        isLoading: false,
        lastAdviceAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        advice: '今日もよく頑張ったね！明日もがんばろう！',
      );
    }
  }
}

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>(
  (ref) => AiCoachNotifier(ref),
);
