import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/onboarding_repository.dart';
import '../domain/user_training_profile.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<UserTrainingProfile?> fetchProfile(String userId) async {
    final data = await _client
        .from('user_training_profile')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;

    return UserTrainingProfile(
      userId: data['user_id'] as String,
      objective: data['objective'] as String,
      level: data['level'] as String,
      daysPerWeek: data['days_per_week'] as int,
      equipment: data['equipment'] as String,
      restrictions: List<String>.from(data['restrictions'] as List),
    );
  }

  @override
  Future<void> saveProfile(UserTrainingProfile profile) async {
    await _client
        .from('user_training_profile')
        .upsert(profile.toJson(), onConflict: 'user_id');
  }
}
