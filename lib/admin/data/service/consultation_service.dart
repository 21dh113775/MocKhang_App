// services/consultation_service.dart
import 'dart:async';
import '../models/consultation_request.dart';

class ConsultationService {
  // Giả lập database với một StreamController
  static final StreamController<List<ConsultationRequest>> _controller =
      StreamController<List<ConsultationRequest>>.broadcast();

  static List<ConsultationRequest> _requests = [];

  // Stream để lắng nghe thay đổi
  static Stream<List<ConsultationRequest>> get requestsStream =>
      _controller.stream;

  // Thêm yêu cầu mới
  static Future<void> addRequest(ConsultationRequest request) async {
    _requests.add(request);
    _controller.add(_requests);
    // Ở đây bạn sẽ thêm code để lưu vào backend thực tế (Firebase, API, etc.)
  }

  // Lấy tất cả yêu cầu
  static List<ConsultationRequest> getAllRequests() {
    return _requests;
  }

  // Cập nhật trạng thái yêu cầu
  static Future<void> updateRequestStatus(String id, bool isHandled) async {
    final index = _requests.indexWhere((req) => req.id == id);
    if (index != -1) {
      _requests[index].isHandled = isHandled;
      _controller.add(_requests);
      // Thêm code để cập nhật trên backend
    }
  }

  // Xóa yêu cầu
  static Future<void> deleteRequest(String id) async {
    _requests.removeWhere((req) => req.id == id);
    _controller.add(_requests);
    // Thêm code để xóa trên backend
  }

  static void dispose() {
    _controller.close();
  }
}
