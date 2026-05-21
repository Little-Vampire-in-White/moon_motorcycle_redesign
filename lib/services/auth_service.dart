import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moon_motorcycle_redesign/services/api_config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Map<String, dynamic>? _userData;
  String? _token;

  Map<String, dynamic>? get currentUserData => _userData;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userData = data['user'];
        
        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'user', value: jsonEncode(_userData));
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName, String address) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'email': email,
          'password': password,
          'displayName': displayName,
          'address': address,
        }),
      );

      if (response.statusCode == 201) {
        return await login(email, password);
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userData = null;
    await _storage.deleteAll();
  }

  Future<bool> tryAutoLogin() async {
    _token = await _storage.read(key: 'token');
    final userJson = await _storage.read(key: 'user');
    if (_token != null && userJson != null) {
      _userData = jsonDecode(userJson);
      return true;
    }
    return false;
  }

  bool get isLoggedIn => _token != null;
  String? get currentUserId => _userData?['id']?.toString();

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$currentUserId/notifications'),
        headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Helper method for updating profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/$currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        _userData = {...?_userData, ...data};
        await _storage.write(key: 'user', value: jsonEncode(_userData));
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLoginActivity() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$currentUserId/login-activity'),
        headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching login activity: $e');
      return [];
    }
  }

  Future<bool> uploadAvatar(XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/users/$currentUserId/avatar'));
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userData = {...?_userData, 'photoURL': data['url']};
        await _storage.write(key: 'user', value: jsonEncode(_userData));
        return true;
      }
      return false;
    } catch (e) {
      print('Error uploading avatar: $e');
      return false;
    }
  }

  Future<bool> uploadLicense(XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/users/$currentUserId/license'));
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(await http.MultipartFile.fromPath('license', imageFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userData = {...?_userData, 'driverLicenseUrl': data['url']};
        await _storage.write(key: 'user', value: jsonEncode(_userData));
        return true;
      }
      return false;
    } catch (e) {
      print('Error uploading license: $e');
      return false;
    }
  }
}
