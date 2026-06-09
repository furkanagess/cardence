import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class UploadProfilePhoto {
  const UploadProfilePhoto(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call(String filePath) =>
      _repository.uploadProfilePhoto(filePath);
}
