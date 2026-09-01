import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String? gender;
  final Map<String, dynamic>? measurements;
  final DateTime? timestamp;

  CustomerModel({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    this.gender,
    this.measurements,
    this.timestamp,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> data, String id) {
    return CustomerModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'],
      measurements: data['measurements'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'gender': gender,
      'measurements': measurements,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }
}
