import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/login_screen.dart';
import 'package:moon_motorcycle_redesign/services/notification_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: [
            _buildPage(
              title: 'Welcome to MOON',
              description: 'Find and book your dream motorcycle for your next adventure.',
              imageUrl: 'https://i.ibb.co/6g3b1PS/Screenshot-2024-05-22-123306.png',
              onNext: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
            ),
            _buildPage(
              title: 'Enable Notifications',
              description: 'Get updates on your bookings, messages, and other important news.',
              imageUrl: 'https://i.ibb.co/g62P5S2/Screenshot-2024-05-22-123320.png', // Placeholder, can be changed
              isLastPage: true,
              onNext: () async {
                await _notificationService.requestPermission();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              buttonText: 'Allow Notifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String imageUrl,
    required VoidCallback onNext,
    bool isLastPage = false,
    String? buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  imageUrl,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 100, color: Colors.red),
                ),
                const SizedBox(height: 40),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (isLastPage)
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  buttonText ?? 'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 32),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
