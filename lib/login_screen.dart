import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/home_page.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';
import 'package:moon_motorcycle_redesign/signup_screen.dart';
import 'package:moon_motorcycle_redesign/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Account',
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Hello, Welcome back to your account.',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Email'),
                  Tab(text: 'Phone no.'),
                ],
                labelStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                indicator: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(15),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 240, // Adjusted to prevent overflow
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmailLogin(),
                  Center(child: Text('Phone login coming soon', style: GoogleFonts.poppins())),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Social login options',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Social login is currently disabled')),
                  );
                },
                icon: Image.network(
                  'http://pngimg.com/uploads/google/google_PNG19635.png', 
                  height: 24,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                  ),
                label: Text(
                  'Google',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupScreen()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No registered yet? ',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Text(
                    'Create an account',
                    style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailLogin() {
    return Column(
      children: [
        _buildTextField(label: 'Email', hint: 'Enter your email', controller: _emailController),
        const SizedBox(height: 20),
        _buildTextField(label: 'Password', hint: 'Enter your password', controller: _passwordController, obscureText: true),
        const SizedBox(height: 20),
        SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final success = await _authService.login(_emailController.text, _passwordController.text);
                if (success) {
                  _notificationService.showLoginNotification();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
                  }
                } else {
                   if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed. Check your credentials.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneLogin() {
    return Column(
      children: [
        _buildTextField(label: 'Phone no.', hint: 'Enter your phone number', controller: _phoneController),
        const SizedBox(height: 20),
         SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone login is currently disabled')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Request OTP',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}
