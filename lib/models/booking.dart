class Booking {
  final String id;
  final String userId;
  final String motorcycleId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final String status; // e.g., 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final String? motorcycleName;
  final String? imageUrl;
  final String? userName;

  Booking({
    required this.id,
    required this.userId,
    required this.motorcycleId,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    this.status = 'pending',
    this.rejectionReason,
    this.motorcycleName,
    this.imageUrl,
    this.userName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Booking(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      motorcycleId: json['motorcycleId']?.toString() ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalCost: parseDouble(json['totalCost']),
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
      motorcycleName: json['motorcycleName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      userName: json['userName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'motorcycleId': motorcycleId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCost': totalCost,
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }
}
