import '../entities/profile_stats.dart';
import '../repositories/profile_repository.dart';

class GetProfileStats {
  const GetProfileStats(this._repository);

  final ProfileRepository _repository;

  Future<ProfileStats> call() => _repository.getProfileStats();
}
