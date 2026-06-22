import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../workout_engine/domain/workout_plan.dart';
import 'session_provider.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.day, required this.planId});

  final WorkoutDay day;
  final String planId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  final _repsCtrl = TextEditingController(text: '12');
  final _weightCtrl = TextEditingController(text: '0');
  final _rirCtrl = TextEditingController(text: '2');
  Timer? _timer;
  int _elapsed = 0;
  int _restCountdown = 0;
  Timer? _restTimer;

  ({WorkoutDay day, String planId}) get _arg =>
      (day: widget.day, planId: widget.planId);

  @override
  void initState() {
    super.initState();
    // Inicia a sessão no Supabase e o cronômetro
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(sessionProvider(_arg).notifier).start();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  void _startRestCountdown(int seconds) {
    _restTimer?.cancel();
    setState(() => _restCountdown = seconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_restCountdown > 0) {
          _restCountdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _rirCtrl.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider(_arg));

    // Navega ao finalizar
    ref.listen(sessionProvider(_arg), (_, next) {
      if (next.isFinished) {
        _timer?.cancel();
        context.go('/home');
      }
    });

    if (session.isFinished || session.isSaving) {
      return const Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.green, size: 72),
              SizedBox(height: 16),
              Text('Treino concluído!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Salvando resultado...',
                  style: TextStyle(color: Colors.white60)),
            ],
          ),
        ),
      );
    }

    final exercise = session.currentExercise;
    final progress =
        (session.currentExerciseIndex * 100 + session.currentSetIndex * 10) /
            (session.totalExercises * 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          widget.day.label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => _confirmExit(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatTime(_elapsed),
                style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progresso geral
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.grey.withAlpha(40),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Indicador de exercício atual
                  _ExerciseCounter(
                    current: session.currentExerciseIndex + 1,
                    total: session.totalExercises,
                  ),
                  const SizedBox(height: 16),

                  // Card do exercício
                  _ExerciseCard(
                    exercise: exercise,
                    currentSet: session.currentSetIndex + 1,
                  ),
                  const SizedBox(height: 20),

                  // Countdown de descanso
                  if (_restCountdown > 0)
                    _RestCountdown(seconds: _restCountdown),

                  if (_restCountdown == 0) ...[
                    // Campos de input
                    _InputRow(
                      repsCtrl: _repsCtrl,
                      weightCtrl: _weightCtrl,
                      rirCtrl: _rirCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Botões de ação
                    FilledButton(
                      onPressed: () {
                        final reps = int.tryParse(_repsCtrl.text);
                        final weight = double.tryParse(
                            _weightCtrl.text.replaceAll(',', '.'));
                        final rir = int.tryParse(_rirCtrl.text);

                        ref.read(sessionProvider(_arg).notifier).logSet(
                              repsDone: reps,
                              weightKg: weight,
                              rirReported: rir,
                            );

                        // Inicia descanso se não for o último
                        if (!session.isLastExercise || !session.isLastSet) {
                          _startRestCountdown(exercise.restSeconds);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        session.isLastExercise && session.isLastSet
                            ? 'Finalizar treino'
                            : 'Confirmar série',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () =>
                          ref.read(sessionProvider(_arg).notifier).skipSet(),
                      child: const Text('Pular série',
                          style: TextStyle(color: AppColors.grey)),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Lista de próximos exercícios
                  _UpcomingList(
                    exercises: widget.day.exercises,
                    currentIndex: session.currentExerciseIndex,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair do treino?'),
        content: const Text(
            'O progresso registrado será salvo, mas o treino ficará incompleto.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar treino'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) context.go('/home');
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _ExerciseCounter extends StatelessWidget {
  const _ExerciseCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Exercício $current de $total',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: AppColors.grey),
        ),
        const Spacer(),
        ...List.generate(total, (i) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < current ? AppColors.green : AppColors.grey.withAlpha(60),
            ),
          );
        }),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.currentSet});

  final PlannedExercise exercise;
  final int currentSet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exercise.primaryMuscle,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetaChip(
                label: 'Série $currentSet/${exercise.sets}',
                icon: Icons.repeat,
              ),
              const SizedBox(width: 8),
              _MetaChip(
                label: '${exercise.repsMin}–${exercise.repsMax} reps',
                icon: Icons.bar_chart,
              ),
              const SizedBox(width: 8),
              _MetaChip(
                label: 'RIR ${exercise.rir}',
                icon: Icons.speed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.green),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _RestCountdown extends StatelessWidget {
  const _RestCountdown({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withAlpha(60)),
      ),
      child: Column(
        children: [
          const Text('Descanso',
              style: TextStyle(color: AppColors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            '${seconds}s',
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Prepare-se para a próxima série',
              style: TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.repsCtrl,
    required this.weightCtrl,
    required this.rirCtrl,
  });

  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController rirCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NumberInput(
            controller: repsCtrl,
            label: 'Reps feitas',
            suffix: 'reps',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _NumberInput(
            controller: weightCtrl,
            label: 'Carga',
            suffix: 'kg',
            decimal: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _NumberInput(
            controller: rirCtrl,
            label: 'RIR real',
            suffix: 'RIR',
          ),
        ),
      ],
    );
  }
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({
    required this.controller,
    required this.label,
    required this.suffix,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      inputFormatters: [
        decimal
            ? FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList(
      {required this.exercises, required this.currentIndex});

  final List<PlannedExercise> exercises;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final remaining = exercises
        .asMap()
        .entries
        .where((e) => e.key > currentIndex)
        .toList();

    if (remaining.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A seguir',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: 8),
        ...remaining.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.grey.withAlpha(60)),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.value.name,
                    style: const TextStyle(
                        color: AppColors.navy, fontSize: 13),
                  ),
                ),
                Text(
                  '${e.value.sets}×${e.value.repsMin}-${e.value.repsMax}',
                  style: const TextStyle(
                      color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
