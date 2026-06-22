import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'onboarding_provider.dart';
import 'steps/step_objective.dart';
import 'steps/step_level.dart';
import 'steps/step_schedule.dart';
import 'steps/step_restrictions.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  static const _totalPages = 4;

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingDraftProvider);
    final saveState = ref.watch(onboardingSaveProvider);
    final isSaving = saveState is OnboardingSaving;

    ref.listen<OnboardingSaveState>(onboardingSaveProvider, (_, next) {
      if (next is OnboardingSaved) {
        context.go('/home');
      }
      if (next is OnboardingError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
        ref.read(onboardingSaveProvider.notifier).reset();
      }
    });

    final canAdvance = switch (_currentPage) {
      0 => draft.objective != null,
      1 => draft.level != null,
      2 => draft.daysPerWeek != null && draft.equipment != null,
      _ => true,
    };

    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.navy),
                onPressed: _back,
              )
            : null,
        title: _StepIndicator(current: _currentPage, total: _totalPages),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _ProgressBar(progress: (_currentPage + 1) / _totalPages),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _currentPage = p),
              children: const [
                StepObjective(),
                StepLevel(),
                StepSchedule(),
                StepRestrictions(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
            child: FilledButton(
              onPressed: (canAdvance && !isSaving)
                  ? () {
                      if (isLastPage) {
                        ref.read(onboardingSaveProvider.notifier).save();
                      } else {
                        _next();
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isLastPage ? 'Começar meu treino!' : 'Próximo',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: AppColors.grey.withAlpha(40),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Passo ${current + 1} de $total',
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: AppColors.grey),
    );
  }
}
