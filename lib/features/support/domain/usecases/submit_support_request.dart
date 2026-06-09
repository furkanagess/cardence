import '../entities/support_request.dart';
import '../entities/support_request_result.dart';
import '../repositories/support_repository.dart';

class SubmitSupportRequest {
  const SubmitSupportRequest(this._repository);

  final SupportRepository _repository;

  Future<SupportRequestResult> call(SupportRequest request) =>
      _repository.submit(request);
}
