import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/account_screen.dart';
import 'package:moon_motorcycle_redesign/change_password_screen.dart';
import 'package:moon_motorcycle_redesign/login_activity_screen.dart';
import 'package:moon_motorcycle_redesign/notifications_screen.dart';
import 'package:moon_motorcycle_redesign/onboarding_screen.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

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
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            color: Colors.orange,
            context: context,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            color: Colors.purple,
            context: context,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy settings coming soon!'))),
          ),
          _buildSettingsTile(icon: Icons.security_outlined, title: 'Security', color: Colors.teal, context: context, onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SecurityScreen()));
          }),
          _buildSettingsTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Chat',
            color: Colors.red,
            context: context,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat support coming soon!'))),
          ),
          _buildSettingsTile(icon: Icons.account_circle_outlined, title: 'Account', color: Colors.yellow, context: context, onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AccountScreen()));
          }),
          const Divider(color: Colors.black12, indent: 20, endIndent: 20),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help',
            color: Colors.pink,
            context: context,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help Center coming soon!'))),
          ),
          _buildSettingsTile(icon: Icons.info_outline, title: 'About', color: Colors.blue, context: context),
          _buildSettingsTile(icon: Icons.report_gmailerrorred_outlined, title: 'Report', color: Colors.green, context: context),
          const Divider(color: Colors.black12, indent: 20, endIndent: 20),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.grey,
            context: context,
            onTap: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required Color color, required BuildContext context, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 18),
      onTap: onTap,
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
        title: Text(
          'Security',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSecurityTile(icon: Icons.lock_outline, title: 'Password', color: Colors.orange.shade800, onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
          }),
          _buildSecurityTile(icon: Icons.track_changes_outlined, title: 'Login Activity', color: Colors.purple.shade800, onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginActivityScreen()));
          }),
          _buildSecurityTile(icon: Icons.save_outlined, title: 'Saved Login Info', color: Colors.teal.shade800),
          _buildSecurityTile(icon: Icons.two_k_plus_outlined, title: 'Two-Factor Authentication', color: Colors.red.shade800),
          _buildSecurityTile(icon: Icons.email_outlined, title: 'Email Activity', color: Colors.yellow.shade800),
          _buildSecurityTile(icon: Icons.data_usage_outlined, title: 'Access Data', color: Colors.pink.shade800),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({required IconData icon, required String title, required Color color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
