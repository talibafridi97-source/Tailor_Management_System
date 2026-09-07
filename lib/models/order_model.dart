class OrderModel {
  final String? id;
  final String userId;
  final String clientName;
  final String phone;
  final String garment;
  final String status;
  final double dueAmount;
  final bool isPinned;
  final String? karigarName;
  final DateTime? timestamp;
  final Map<String, dynamic>? measurements;

  OrderModel({
    this.id,
    required this.userId,
    required this.clientName,
    required this.phone,
    required this.garment,
    required this.status,
    required this.dueAmount,
    this.isPinned = false,
    this.karigarName,
    this.timestamp,
    this.measurements,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      clientName: data['clientName'] ?? '',
      phone: data['phone'] ?? '',
      garment: data['garment'] ?? '',
      status: data['status'] ?? 'pending',
      dueAmount: double.tryParse(data['dueAmount'].toString()) ?? 0.0,
      isPinned: data['isPinned'] ?? false,
      karigarName: data['karigarName'],
      timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp'].toString()) : null,
      measurements: data['measurements'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientName': clientName,
      'phone': phone,
      'garment': garment,
      'status': status,
      'dueAmount': dueAmount,
      'isPinned': isPinned,
      'karigarName': karigarName,
      'timestamp': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'measurements': measurements,
    };
  }
}
