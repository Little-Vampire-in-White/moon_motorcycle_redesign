import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/models/booking.dart';
import 'package:moon_motorcycle_redesign/services/booking_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final BookingService _bookingService = BookingService();

  Future<String> _getMotorcycleName(String motorcycleId) async {
    final doc = await FirebaseFirestore.instance.collection('motorcycles').doc(motorcycleId).get();
    return doc.data()?['name'] ?? 'Unknown Motorcycle';
  }

  Future<String> _getUserName(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data()?['displayName'] ?? 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('startDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading bookings'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No booking requests found.'));
          }

          final bookings = snapshot.data!.docs.map((doc) => Booking.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

          return Column(
            children: [
              _buildOrdersChart(bookings),
              Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: _getMotorcycleName(booking.motorcycleId),
                              builder: (context, motorcycleSnapshot) {
                                return Text(
                                  motorcycleSnapshot.data ?? 'Loading...',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<String>(
                              future: _getUserName(booking.userId),
                              builder: (context, userSnapshot) {
                                return Text(
                                  'Requested by: ${userSnapshot.data ?? 'Loading...'}',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dates: ${booking.startDate.toLocal().toString().split(' ')[0]} to ${booking.endDate.toLocal().toString().split(' ')[0]}',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (booking.status == 'pending') ...[
                                  TextButton(onPressed: () => _bookingService.approveBooking(booking.id), child: const Text('Approve')),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _showRejectionDialog(booking.id),
                                    child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                  ),
                                ] else ...[
                                  Text(booking.status.toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: booking.status == 'approved' ? Colors.green : Colors.red)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersChart(List<Booking> bookings) {
    // This is a simplified example. You might want to process dates more robustly.
    final Map<int, int> weeklyData = { for (var i = 0; i < 7; i++) i: 0 };
    final today = DateTime.now();

    for (var booking in bookings) {
      final difference = today.difference(booking.startDate).inDays;
      if (difference >= 0 && difference < 7) {
        weeklyData.update(today.weekday - difference -1, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: weeklyData.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [BarChartRodData(toY: entry.value.toDouble(), color: Colors.teal)],
            );
          }).toList(),
          titlesData: FlTitlesData(
             bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                     const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);
                     String text;
                      switch (value.toInt()) {
                        case 0: text = 'M'; break;
                        case 1: text = 'T'; break;
                        case 2: text = 'W'; break;
                        case 3: text = 'T'; break;
                        case 4: text = 'F'; break;
                        case 5: text = 'S'; break;
                        case 6: text = 'S'; break;
                        default: text = ''; break;
                      }
                      return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                  }
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
           ),
        ),
      ),
    );
  }


  void _showRejectionDialog(String bookingId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _bookingService.rejectBooking(bookingId, reasonController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
