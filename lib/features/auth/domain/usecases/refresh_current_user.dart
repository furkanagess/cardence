import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

/// `/Me` uç noktasından profili önbelleği atlayarak yeniden çeker.
class RefreshCurrentUser {
  const RefreshCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call() => _repository.refreshCurrentUser();
}
