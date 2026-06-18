import '../../domain/entities/profile_stats.dart';

abstract class ProfileRepository {
  Future<ProfileStats> getProfileStats();
}
