import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  Future<void> uploadStory(XFile image, String title, String description) async {
    final user = _authService.currentUser;
    if (user == null) return;

    // 1. Upload the image to Firebase Storage
    final ref = _storage.ref().child('story_images').child('${DateTime.now().toIso8601String()}_${user.uid}');
    final uploadTask = await ref.putFile(File(image.path));
    final imageUrl = await uploadTask.ref.getDownloadURL();

    // 2. Add the story data to Firestore
    await _firestore.collection('stories').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'authorId': user.uid,
      'authorName': user.displayName ?? 'Anonymous',
      'authorAvatarUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
