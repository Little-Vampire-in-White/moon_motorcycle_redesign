import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moon_motorcycle_redesign/models/booking.dart';
import 'package:moon_motorcycle_redesign/services/api_config.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final _authService = AuthService();

  Future<bool> createBooking(Booking booking) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(booking.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bookings/my-bookings'),
        headers: {
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Booking.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }
}
