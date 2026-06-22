import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/progress_summary.dart';
import 'progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Minha Evolução',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.invalidate(progressSummaryProvider),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (summary) => summary.totalSessions == 0
            ? const _EmptyState()
            : _SummaryView(summary: summary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sem histórico ainda
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart, size: 72, color: AppColors.green),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino registrado ainda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete seu primeiro treino para ver sua evolução aqui.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dados de evolução
// ---------------------------------------------------------------------------
class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Cards de estatísticas
        SliverToBoxAdapter(
          child: _StatsHeader(summary: summary),
        ),

        // Gráfico de volume por exercício (se houver)
        if (summary.volumeByExercise.isNotEmpty) ...[
          const SliverToBoxAdapter(child: _SectionTitle(title: 'Evolução de Carga')),
          SliverToBoxAdapter(
            child: _VolumeChart(volumeByExercise: summary.volumeByExercise),
          ),
        ],

        // Histórico de sessões
        const SliverToBoxAdapter(
            child: _SectionTitle(title: 'Histórico de Treinos')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList.separated(
            itemCount: summary.recentSessions.length,
            separatorBuilder: (_, i) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _SessionCard(session: summary.recentSessions[i]),
          ),
        ),
      ],
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '${summary.totalSessions}',
            label: 'Treinos',
            icon: Icons.fitness_center,
          ),
          _StatItem(
            value: '${summary.totalMinutes}min',
            label: 'Total',
            icon: Icons.timer,
          ),
          _StatItem(
            value: '${summary.currentStreak}d',
            label: 'Sequência',
            icon: Icons.local_fire_department,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.green, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gráfico de barras manual — evolução de carga por exercício
// ---------------------------------------------------------------------------
class _VolumeChart extends StatefulWidget {
  const _VolumeChart({required this.volumeByExercise});

  final Map<String, List<ExerciseVolume>> volumeByExercise;

  @override
  State<_VolumeChart> createState() => _VolumeChartState();
}

class _VolumeChartState extends State<_VolumeChart> {
  late String _selectedExercise;

  @override
  void initState() {
    super.initState();
    _selectedExercise = widget.volumeByExercise.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.volumeByExercise[_selectedExercise] ?? [];
    final maxWeight =
        data.fold(0.0, (m, e) => e.maxWeightKg > m ? e.maxWeightKg : m);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Seletor de exercício
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.volumeByExercise.keys.map((name) {
                final selected = name == _selectedExercise;
                return GestureDetector(
                  onTap: () => setState(() => _selectedExercise = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.navy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.navy
                            : AppColors.grey.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.navy,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Barras
          if (data.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Sem dados de carga para este exercício.',
                  style: TextStyle(color: AppColors.grey, fontSize: 13)),
            )
          else
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((e) {
                  final ratio = maxWeight > 0 ? e.maxWeightKg / maxWeight : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            e.maxWeightKg > 0
                                ? '${e.maxWeightKg.toStringAsFixed(1)}kg'
                                : '',
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.navy),
                          ),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 100 * ratio,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${e.date.day}/${e.date.month}',
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de sessão no histórico
// ---------------------------------------------------------------------------
class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final SessionSummary session;

  @override
  Widget build(BuildContext context) {
    final date = session.performedAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center,
                  color: AppColors.green, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.dayLabel,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$dateStr às $timeStr',
                    style: const TextStyle(
                        color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  session.durationFormatted,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Icon(Icons.check_circle,
                    color: AppColors.green, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }
}
