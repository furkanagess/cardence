import '../entities/restore_session_result.dart';
import '../repositories/auth_repository.dart';

class RestoreAuthSession {
  const RestoreAuthSession(this._repository);

  final AuthRepository _repository;

  Future<RestoreSessionResult> call() => _repository.restoreSession();
}
