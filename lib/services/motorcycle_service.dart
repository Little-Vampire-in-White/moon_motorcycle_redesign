import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';
import 'package:moon_motorcycle_redesign/services/api_config.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class MotorcycleService {
  static final MotorcycleService _instance = MotorcycleService._internal();
  factory MotorcycleService() => _instance;
  MotorcycleService._internal();

  final _authService = AuthService();

  Future<List<Motorcycle>> getMotorcycles() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/motorcycles'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Motorcycle.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching motorcycles: $e');
      return [];
    }
  }

  Future<Motorcycle?> getMotorcycleById(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/motorcycles/$id'));
      if (response.statusCode == 200) {
        return Motorcycle.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching motorcycle $id: $e');
      return null;
    }
  }

  Future<bool> addMotorcycle(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/motorcycles'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding motorcycle: $e');
      return false;
    }
  }

  Future<bool> updateMotorcycle(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/motorcycles/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating motorcycle: $e');
      return false;
    }
  }

  Future<bool> deleteMotorcycle(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/motorcycles/$id'),
        headers: {
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting motorcycle: $e');
      return false;
    }
  }
}
