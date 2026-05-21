import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moon_motorcycle_redesign/services/api_config.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class Story {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      authorName: json['authorName'] ?? 'Anonymous',
      authorAvatarUrl: json['authorAvatarUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class StoryService {
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  final _authService = AuthService();

  Future<List<Story>> getStories() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/stories'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Story.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching stories: $e');
      return [];
    }
  }

  Future<List<Story>> getStoriesByAuthor(String authorId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/stories/author/$authorId'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Story.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching stories by author: $e');
      return [];
    }
  }

  Future<bool> uploadStory(XFile imageFile, String title, String description) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/stories'));
      
      if (_authService.token != null) {
        request.headers['Authorization'] = 'Bearer ${_authService.token}';
      }

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['authorId'] = _authService.currentUserId ?? '';
      request.fields['authorName'] = _authService.currentUserData?['displayName'] ?? 'Anonymous';
      if (_authService.currentUserData?['photoURL'] != null) {
         request.fields['authorAvatarUrl'] = _authService.currentUserData?['photoURL'];
      }

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      print('Error uploading story: $e');
      return false;
    }
  }
}
