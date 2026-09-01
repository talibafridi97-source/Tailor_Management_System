// import 'package:cloud_firestore/cloud_firestore.dart'; // TODO: Replace with MongoDB equivalent

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
      // TODO: Replace with MongoDB logic
      timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp'].toString()) : null,
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
      // TODO: Replace with MongoDB server timestamp
      'timestamp': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
