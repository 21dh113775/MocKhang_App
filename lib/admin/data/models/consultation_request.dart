// models/consultation_request.dart
class ConsultationRequest {
  final String id;
  final String topic;
  final String name;
  final String phone;
  final String email;
  final String message;
  final DateTime timestamp;
  bool isHandled;

  ConsultationRequest({
    required this.id,
    required this.topic,
    required this.name,
    required this.phone,
    required this.email,
    required this.message,
    required this.timestamp,
    this.isHandled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'name': name,
      'phone': phone,
      'email': email,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isHandled': isHandled,
    };
  }

  factory ConsultationRequest.fromMap(Map<String, dynamic> map) {
    return ConsultationRequest(
      id: map['id'],
      topic: map['topic'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      message: map['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isHandled: map['isHandled'] ?? false,
    );
  }
}
