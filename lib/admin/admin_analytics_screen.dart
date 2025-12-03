import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final AuthService _authService = AuthService();
  double? _totalSales;
  double? _averageSales;
  List<Map<String, dynamic>>? _trendingItems;
  Map<int, double>? _weeklyApprovedSales;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() async {
    _totalSales = await _authService.getTotalSales();
    _averageSales = await _authService.getAverageSales();
    _trendingItems = await _authService.getTrendingMotorcycles();
    _weeklyApprovedSales = await _authService.getWeeklyChartData('approved');
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
        title: Text('Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSummaryCard(title: 'Total Sales', value: '\$${_totalSales?.toStringAsFixed(2) ?? '-'}', icon: Icons.show_chart)),
                const SizedBox(width: 20),
                Expanded(child: _buildSummaryCard(title: 'Average Sales', value: '\$${_averageSales?.toStringAsFixed(2) ?? '-'}', icon: Icons.stacked_line_chart)),
              ],
            ),
            const SizedBox(height: 30),
            _buildChartOrders(),
            const SizedBox(height: 30),
            _buildTrendingItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.teal),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChartOrders() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: _weeklyApprovedSales == null
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
                    spots: _weeklyApprovedSales!.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTrendingItems() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trending Items', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (_trendingItems == null)
            const Center(child: CircularProgressIndicator())
          else if (_trendingItems!.isEmpty)
            const Center(child: Text('No trending items yet.'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trendingItems!.length,
              itemBuilder: (context, index) {
                final item = _trendingItems![index];
                return ListTile(
                  leading: Image.network(item['imageUrl'] ?? '', width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item['name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  trailing: Text('${item['bookings']} bookings', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
        ],
      ),
    );
  }
}
