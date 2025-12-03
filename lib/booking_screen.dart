import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/models/booking.dart';
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';
import 'package:moon_motorcycle_redesign/services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final Motorcycle motorcycle;
  const BookingScreen({super.key, required this.motorcycle});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();
  DateTime? _startDate;
  DateTime? _endDate;

  void _presentDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((pickedDateRange) {
      if (pickedDateRange == null) {
        return;
      }
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
    });
  }

  double _calculateTotalCost() {
    if (_startDate == null || _endDate == null) {
      return 0.0;
    }
    final numberOfDays = _endDate!.difference(_startDate!).inDays + 1;
    return numberOfDays * widget.motorcycle.price;
  }

  void _requestBooking() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date range.')));
      return;
    }

    final newBooking = Booking(
      id: '', // Firestore will generate this
      userId: _authService.currentUser!.uid,
      motorcycleId: widget.motorcycle.id,
      startDate: _startDate!,
      endDate: _endDate!,
      totalCost: _calculateTotalCost(),
    );

    _bookingService.createBooking(newBooking).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking request sent!')));
      Navigator.of(context).pop();
    }).catchError((_) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send booking request.')));
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Motorcycle', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.motorcycle.name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDatePickerTile(
              label: 'Start Date',
              date: _startDate,
              onTap: _presentDatePicker,
            ),
            const SizedBox(height: 10),
            _buildDatePickerTile(
              label: 'End Date',
              date: _endDate,
              onTap: _presentDatePicker,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Cost:', style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey[700])),
                Text('\$${_calculateTotalCost().toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_startDate != null && _endDate != null) ? _requestBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('Request to Book', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile({required String label, DateTime? date, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF1A1A2E)),
      title: Text(
        date == null ? label : '${date.toLocal()}'.split(' ')[0],
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
