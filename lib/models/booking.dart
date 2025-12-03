import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String motorcycleId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final String status; // e.g., 'pending', 'approved', 'rejected'
  final String? rejectionReason;

  Booking({
    required this.id,
    required this.userId,
    required this.motorcycleId,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    this.status = 'pending',
    this.rejectionReason,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> data) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      motorcycleId: data['motorcycleId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalCost: (data['totalCost'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'motorcycleId': motorcycleId,
      'startDate': startDate,
      'endDate': endDate,
      'totalCost': totalCost,
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }
}
