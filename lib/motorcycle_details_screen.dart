import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/booking_screen.dart';
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MotorcycleDetailsScreen extends StatefulWidget {
  final Motorcycle motorcycle;
  const MotorcycleDetailsScreen({super.key, required this.motorcycle});

  @override
  State<MotorcycleDetailsScreen> createState() => _MotorcycleDetailsScreenState();
}

class _MotorcycleDetailsScreenState extends State<MotorcycleDetailsScreen> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final List<String> _images = [widget.motorcycle.imageUrl];

    return Scaffold(
      body: Stack(
        children: [
          // --- Image Carousel ---
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55, // Take up more of the screen
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.two_wheeler,
                        color: Colors.grey[400],
                        size: 100,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- App Bar ---
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 32),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white, size: 32),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // --- Details Card ---
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.motorcycle.name.split(' ').first, // Assumes brand is the first word
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.motorcycle.name,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'From \$${widget.motorcycle.price.toStringAsFixed(2)} / day',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.star, color: Colors.amber, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              '4.6', // Placeholder
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(204 reviews)', // Placeholder
                              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            MotorcycleStat(label: 'Engine', value: widget.motorcycle.engine),
                            MotorcycleStat(label: 'Power', value: widget.motorcycle.power),
                            MotorcycleStat(label: 'Torque', value: widget.motorcycle.torque),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          widget.motorcycle.description,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // --- Page Indicator and Book Now Button ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _images.length,
                    effect: const ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Color(0xFFF96E46),
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookingScreen(motorcycle: widget.motorcycle)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Book now',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MotorcycleStat extends StatelessWidget {
  final String label;
  final String value;

  const MotorcycleStat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
