import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/progress_repository_impl.dart';
import '../domain/progress_repository.dart';
import '../domain/progress_summary.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(Supabase.instance.client);
});

final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) throw Exception('Usuário não autenticado');
  return ref.read(progressRepositoryProvider).fetchSummary(userId: userId);
});
