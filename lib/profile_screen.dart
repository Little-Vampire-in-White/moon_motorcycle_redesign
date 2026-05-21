import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moon_motorcycle_redesign/models/booking.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';
import 'package:moon_motorcycle_redesign/services/booking_service.dart';
import 'package:moon_motorcycle_redesign/services/story_service.dart';
import 'package:moon_motorcycle_redesign/services/motorcycle_service.dart';
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';
import 'package:moon_motorcycle_redesign/settings_screen.dart';
import 'package:moon_motorcycle_redesign/upload_story_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final StoryService _storyService = StoryService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = _authService.currentUserData;
    final displayName = userData?['displayName'] ?? 'Motorcycle Rider';
    final address = userData?['address'] ?? 'Address Not Set';
    final avatar = userData?['photoURL'] != null && userData!['photoURL'].isNotEmpty
        ? NetworkImage(userData['photoURL'])
        : const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1887&auto=format&fit=crop');

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: const Color(0xFF2C3E50),
              expandedHeight: 320.0,
              floating: false,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 32),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                    if (mounted) setState(() {});
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=2070&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          GestureDetector(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                final success = await _authService.uploadAvatar(image);
                                if (success) {
                                  setState(() {});
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Profile picture updated successfully!')),
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to update profile picture.')),
                                    );
                                  }
                                }
                              }
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 55,
                                  backgroundImage: avatar,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Color(0xFF1A1A2E), size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            address,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'My Bookings'),
                    Tab(text: 'My Stories'),
                  ],
                  labelStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  indicatorWeight: 3.0,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyBookings(),
            _buildMyStories(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookings() {
    return FutureBuilder<List<Booking>>(
      future: _bookingService.getUserBookings(_authService.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('You have no bookings.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)));
        }

        final bookings = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return FutureBuilder<Motorcycle?>(
              future: MotorcycleService().getMotorcycleById(booking.motorcycleId),
              builder: (context, motorcycleSnapshot) {
                if (!motorcycleSnapshot.hasData) {
                  return const SizedBox();
                }
                final motorcycleData = motorcycleSnapshot.data!;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            motorcycleData.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler, size: 50),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(motorcycleData.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 8),
                              Text('Status: ${booking.status}', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: booking.status == 'approved' ? Colors.green : Colors.orange)),
                              Text('From: ${booking.startDate.toLocal().toString().split(' ')[0]}', style: GoogleFonts.poppins()),
                              Text('To:     ${booking.endDate.toLocal().toString().split(' ')[0]}', style: GoogleFonts.poppins()),
                              const SizedBox(height: 8),
                              Text('\$${booking.totalCost.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMyStories() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadStoryScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: FutureBuilder<List<Story>>(
        future: _storyService.getStoriesByAuthor(_authService.currentUserId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('You haven\'t posted any stories yet.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)));
        }

        final stories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      story.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(story.createdAt),
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
