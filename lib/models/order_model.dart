import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final String userId;
  final String clientName;
  final String phone;
  final String garment;
  final String status;
  final double dueAmount;
  final bool isPinned;
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
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
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
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'measurements': measurements,
    };
  }
}
