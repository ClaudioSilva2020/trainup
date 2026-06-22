import 'user_training_profile.dart';

abstract interface class OnboardingRepository {
  Future<UserTrainingProfile?> fetchProfile(String userId);
  Future<void> saveProfile(UserTrainingProfile profile);
}
