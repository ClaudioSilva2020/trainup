import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/trainup_logo.dart';

/// Mock da Home do aluno — "treino de hoje" gerado pelo motor de regras (RF-002).
///
/// Os dados abaixo são estáticos apenas para apresentação ao cliente.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _exercises = [
    _ExerciseItem(
      name: 'Supino reto com halteres',
      muscle: 'Peito',
      sets: '4 séries x 8-12 reps',
    ),
    _ExerciseItem(
      name: 'Desenvolvimento de ombro',
      muscle: 'Ombro',
      sets: '3 séries x 8-12 reps',
    ),
    _ExerciseItem(
      name: 'Tríceps corda',
      muscle: 'Tríceps',
      sets: '3 séries x 10-12 reps',
    ),
    _ExerciseItem(
      name: 'Flexão de braço',
      muscle: 'Peito / Tríceps',
      sets: '3 séries x até a falha',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrainUpLogo(
          variant: TrainUpLogoVariant.icon,
          height: 32,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.green,
              child: Text('A', style: TextStyle(color: AppColors.navy)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Olá, Ana 👋',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Semana 2 de 4 · Plano gerado automaticamente',
            style: TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 20),
          _TodayWorkoutCard(exercises: _exercises),
          const SizedBox(height: 20),
          const _ProgressCard(),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.exercises});

  final List<_ExerciseItem> exercises;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TREINO DE HOJE',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Push — Peito, Ombro e Tríceps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (final exercise in exercises) _ExerciseRow(exercise: exercise),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Iniciar treino'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise});

  final _ExerciseItem exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.navy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${exercise.muscle} · ${exercise.sets}',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sua evolução',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _ProgressStat(label: 'Treinos no mês', value: '6'),
                _ProgressStat(label: 'Peso atual', value: '78,2 kg'),
                _ProgressStat(label: 'Sequência', value: '3 dias'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ExerciseItem {
  const _ExerciseItem({
    required this.name,
    required this.muscle,
    required this.sets,
  });

  final String name;
  final String muscle;
  final String sets;
}
