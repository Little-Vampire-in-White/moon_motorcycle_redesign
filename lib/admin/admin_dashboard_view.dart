import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/admin/user_management_screen.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final AuthService _authService = AuthService();
  int? _totalProducts;
  int? _totalBookings;
  int? _totalUsers;
  double? _revenue;
  Map<int, double>? _weeklyRevenue;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    _totalProducts = await _authService.getTotalProducts();
    _totalBookings = await _authService.getTotalBookings();
    _totalUsers = await _authService.getTotalUsers();
    _revenue = await _authService.getRevenue();
    _weeklyRevenue = await _authService.getWeeklyChartData('all');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          // CircleAvatar removed
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSummaryCard(title: 'Total Motorcycles', value: _totalProducts?.toString() ?? '-', percentage: 0.3, color: Colors.black)),
                const SizedBox(width: 20),
                Expanded(child: _buildSummaryCard(title: 'Total Bookings', value: _totalBookings?.toString() ?? '-', percentage: 0.7, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSummaryCard(title: 'Total Users', value: _totalUsers?.toString() ?? '-', percentage: 0.7, color: Colors.lightGreen)),
                const SizedBox(width: 20),
                Expanded(child: _buildSummaryCard(title: 'Revenue', value: '\$${_revenue?.toStringAsFixed(2) ?? '-'}', percentage: 0.7, color: Colors.pink)),
              ],
            ),
            const SizedBox(height: 30),
            _buildRevenueChart(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
              label: Text('Manage Users', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserManagementScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                minimumSize: const Size(double.infinity, 50), // full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required double percentage, required Color color}) {
    final bool isDark = color == Colors.black;
    final Color textColor = isDark ? Colors.white70 : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: textColor),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white : color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("0%", style: GoogleFonts.poppins(color: textColor, fontSize: 12)),
              Text("${(percentage * 100).toInt()}%", style: GoogleFonts.poppins(color: textColor, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: _weeklyRevenue == null
          ? const Center(child: CircularProgressIndicator())
          : LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'S'; break;
                          case 1: text = 'M'; break;
                          case 2: text = 'T'; break;
                          case 3: text = 'W'; break;
                          case 4: text = 'T'; break;
                          case 5: text = 'F'; break;
                          case 6: text = 'S'; break;
                          default: text = ''; break;
                        }
                        return Text(text, style: style);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _weeklyRevenue!.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.pink,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
    );
  }
}
