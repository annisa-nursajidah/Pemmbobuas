import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final String userId;
  final String serviceId;
  final String serviceTitle;
  final String mitraName; // nama mitra penyedia jasa
  final String customerName;
  final String phone;
  final String address;
  final String notes;
  final String status;
  final double totalPrice;
  final Timestamp? createdAt;

  OrderModel({
    this.id,
    this.userId = '',
    required this.serviceId,
    required this.serviceTitle,
    this.mitraName = '',
    required this.customerName,
    required this.phone,
    required this.address,
    required this.notes,
    required this.status,
    required this.totalPrice,
    this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceTitle: data['serviceTitle'] ?? '',
      mitraName: data['mitraName'] ?? '',
      customerName: data['customerName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'pending',
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'mitraName': mitraName,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

