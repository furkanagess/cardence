import '../entities/support_request.dart';
import '../entities/support_request_result.dart';

abstract class SupportRepository {
  Future<SupportRequestResult> submit(SupportRequest request);
}
