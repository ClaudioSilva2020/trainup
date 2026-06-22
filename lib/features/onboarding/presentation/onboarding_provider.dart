import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/onboarding_repository_impl.dart';
import '../domain/onboarding_repository.dart';
import '../domain/user_training_profile.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(Supabase.instance.client);
});

// Draft preenchido passo a passo antes de salvar
class OnboardingDraft {
  const OnboardingDraft({
    this.objective,
    this.level,
    this.daysPerWeek,
    this.equipment,
    this.restrictions = const [],
  });

  final String? objective;
  final String? level;
  final int? daysPerWeek;
  final String? equipment;
  final List<String> restrictions;

  OnboardingDraft copyWith({
    String? objective,
    String? level,
    int? daysPerWeek,
    String? equipment,
    List<String>? restrictions,
  }) =>
      OnboardingDraft(
        objective: objective ?? this.objective,
        level: level ?? this.level,
        daysPerWeek: daysPerWeek ?? this.daysPerWeek,
        equipment: equipment ?? this.equipment,
        restrictions: restrictions ?? this.restrictions,
      );

  bool get isComplete =>
      objective != null &&
      level != null &&
      daysPerWeek != null &&
      equipment != null;
}

sealed class OnboardingSaveState {
  const OnboardingSaveState();
}

class OnboardingIdle extends OnboardingSaveState {
  const OnboardingIdle();
}

class OnboardingSaving extends OnboardingSaveState {
  const OnboardingSaving();
}

class OnboardingSaved extends OnboardingSaveState {
  const OnboardingSaved();
}

class OnboardingError extends OnboardingSaveState {
  const OnboardingError(this.message);
  final String message;
}

class OnboardingNotifier extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void setObjective(String v) => state = state.copyWith(objective: v);
  void setLevel(String v) => state = state.copyWith(level: v);
  void setDaysPerWeek(int v) => state = state.copyWith(daysPerWeek: v);
  void setEquipment(String v) => state = state.copyWith(equipment: v);

  void toggleRestriction(String r) {
    final list = List<String>.from(state.restrictions);
    list.contains(r) ? list.remove(r) : list.add(r);
    state = state.copyWith(restrictions: list);
  }
}

final onboardingDraftProvider =
    NotifierProvider<OnboardingNotifier, OnboardingDraft>(
        OnboardingNotifier.new);

class OnboardingSaveNotifier extends Notifier<OnboardingSaveState> {
  @override
  OnboardingSaveState build() => const OnboardingIdle();

  Future<void> save() async {
    final draft = ref.read(onboardingDraftProvider);
    if (!draft.isComplete) return;

    final userId = Supabase.instance.client.auth.currentUser!.id;
    state = const OnboardingSaving();
    try {
      await ref.read(onboardingRepositoryProvider).saveProfile(
            UserTrainingProfile(
              userId: userId,
              objective: draft.objective!,
              level: draft.level!,
              daysPerWeek: draft.daysPerWeek!,
              equipment: draft.equipment!,
              restrictions: draft.restrictions,
            ),
          );
      state = const OnboardingSaved();
    } catch (e) {
      state = OnboardingError('Erro ao salvar perfil: $e');
    }
  }

  void reset() => state = const OnboardingIdle();
}

final onboardingSaveProvider =
    NotifierProvider<OnboardingSaveNotifier, OnboardingSaveState>(
        OnboardingSaveNotifier.new);
