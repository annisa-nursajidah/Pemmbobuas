import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String title;
  final String category;
  final String mitraName;
  final String mitraAvatarUrl;
  final double mitraRating;
  final int totalOrders;
  final double price;
  final String description;
  final String imageUrl;
  final bool isEscrow;
  final String responseTime;
  final String city;
  final bool isFeatured;
  final List<ServicePackage> packages;

  ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.mitraName,
    required this.mitraAvatarUrl,
    required this.mitraRating,
    required this.totalOrders,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.isEscrow,
    required this.responseTime,
    required this.city,
    required this.isFeatured,
    required this.packages,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      mitraName: data['mitraName'] ?? '',
      mitraAvatarUrl: data['mitraAvatarUrl'] ?? '',
      mitraRating: (data['mitraRating'] ?? 0.0).toDouble(),
      totalOrders: (data['totalOrders'] ?? 0).toInt(),
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isEscrow: data['isEscrow'] ?? false,
      responseTime: data['responseTime'] ?? '',
      city: data['city'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      packages: ((data['packages'] ?? []) as List)
          .map((p) => ServicePackage.fromMap(p))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'mitraName': mitraName,
      'mitraAvatarUrl': mitraAvatarUrl,
      'mitraRating': mitraRating,
      'totalOrders': totalOrders,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'isEscrow': isEscrow,
      'responseTime': responseTime,
      'city': city,
      'isFeatured': isFeatured,
      'packages': packages.map((p) => p.toMap()).toList(),
    };
  }
}

class ServicePackage {
  final String name;
  final double price;
  final String description;

  ServicePackage({
    required this.name,
    required this.price,
    required this.description,
  });

  factory ServicePackage.fromMap(Map<String, dynamic> map) {
    return ServicePackage(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }
}
