import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryViewScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final String? authorAvatarUrl; // Make this nullable
  final String date;
  final String description;

  const StoryViewScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
    this.authorAvatarUrl,
    required this.date,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = (authorAvatarUrl != null && authorAvatarUrl!.isNotEmpty)
        ? NetworkImage(authorAvatarUrl!)
        : const NetworkImage('https://p7.hiclipart.com/preview/312/283/679/user-profile-get-em-card-linkedin-logo-social-media-silhouette.jpg');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.network(imageUrl, fit: BoxFit.contain),
                      ),
                    ),
                  );
                }));
              },
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: avatar as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(author, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text(date, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
