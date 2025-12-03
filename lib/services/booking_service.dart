import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moon_motorcycle_redesign/models/booking.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> createBooking(Booking booking) async {
    final user = _authService.currentUser;
    if (user == null) return; // Or throw an error

    await _firestore.collection('bookings').add(booking.toMap());
  }

  Future<void> approveBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': 'approved'});
  }

  Future<void> rejectBooking(String bookingId, String reason) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
  }
}
