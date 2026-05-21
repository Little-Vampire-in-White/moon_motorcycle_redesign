import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';
import 'package:moon_motorcycle_redesign/motorcycle_details_screen.dart';
import 'package:moon_motorcycle_redesign/services/motorcycle_service.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Motorcycle>>(
        future: MotorcycleService().getMotorcycles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading motorcycles'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No motorcycles found.'));
          }

          final motorcycles = snapshot.data!;

          return ListView.builder(
            itemCount: motorcycles.length,
            itemBuilder: (context, index) {
              final motorcycle = motorcycles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MotorcycleDetailsScreen(motorcycle: motorcycle),
                  ));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            motorcycle.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(motorcycle.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 8),
                              _buildSpecRow(Icons.engineering_outlined, 'Engine', motorcycle.engine),
                              _buildSpecRow(Icons.power_outlined, 'Power', motorcycle.power),
                              _buildSpecRow(Icons.speed_outlined, 'Torque', motorcycle.torque),
                              const SizedBox(height: 8),
                              Text('\$${motorcycle.price.toStringAsFixed(2)} / day', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: GoogleFonts.poppins(), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
