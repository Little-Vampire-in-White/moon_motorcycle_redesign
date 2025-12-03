import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';
import 'package:moon_motorcycle_redesign/motorcycle_details_screen.dart';
import 'package:moon_motorcycle_redesign/notifications_screen.dart';
import 'package:moon_motorcycle_redesign/profile_screen.dart';
import 'package:moon_motorcycle_redesign/search_results_screen.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';
import 'package:moon_motorcycle_redesign/story_view_screen.dart';
import 'package:swipable_stack/swipable_stack.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  User? _user;
  // Add a controller to manage the SwipableStack
  late SwipableStackController _swipableStackController;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _swipableStackController = SwipableStackController();
  }

  void _refreshStories() {
    // A way to force rebuild is to re-assign the controller
    // This is a workaround for the package not having a direct reset method.
    setState(() {
      _swipableStackController = SwipableStackController();
    });
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final storyTime = timestamp.toDate();
    final difference = now.difference(storyTime);

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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
            child: Center(
              child: CircleAvatar(
                radius: 28,
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : const NetworkImage('https://p7.hiclipart.com/preview/312/283/679/user-profile-get-em-card-linkedin-logo-social-media-silhouette.jpg'),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            iconSize: 36,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            iconSize: 36,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchResultsScreen()));
            },
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded),
              iconSize: 36,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Go outside and play.',
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Your journey starts now with our finest motorbike selection to rent.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top stories',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshStories,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('See all', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 280,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('stories').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No stories yet.'));
                    }

                    final stories = snapshot.data!.docs;

                    return SwipableStack(
                      controller: _swipableStackController,
                      allowVerticalSwipe: false,
                      stackClipBehaviour: Clip.none,
                      builder: (context, properties) {
                        if (properties.index >= stories.length) {
                          return const Center(child: Text('No more stories.'));
                        }
                        final storyDoc = stories[properties.index];
                        final storyData = storyDoc.data() as Map<String, dynamic>;
                        final timestamp = storyData['createdAt'] as Timestamp?;

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StoryViewScreen(
                                imageUrl: storyData['imageUrl'] ?? '',
                                title: storyData['title'] ?? 'No Title',
                                author: storyData['authorName'] ?? 'Anonymous',
                                authorAvatarUrl: storyData['authorAvatarUrl'],
                                date: _formatTimestamp(timestamp),
                                description: storyData['description'] ?? '',
                              ),
                            ));
                          },
                          child: StoryCard(
                            image: storyData['imageUrl'] ?? '',
                            title: storyData['title'] ?? 'No Title',
                            author: storyData['authorName'] ?? 'Anonymous',
                            date: _formatTimestamp(timestamp),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Motorcycles',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchResultsScreen()));
                    },
                    child: Text('See all', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('motorcycles').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No motorcycles available.'));
                  }

                  final motorcycles = snapshot.data!.docs
                      .map((doc) => Motorcycle.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
            ],
          ),
        ),
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

class StoryCard extends StatelessWidget {
  final String image;
  final String title;
  final String author;
  final String date;

  const StoryCard({
    super.key,
    required this.image,
    required this.title,
    required this.author,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 50,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(author, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(date, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String image;
  final String name;

  const CategoryCard({super.key, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 20),
       decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Image.network(
              image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 50,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            Center(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
