import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task_management/network/api_endpoints.dart';
import 'package:task_management/session/session_manager.dart';

class AuthRepository {
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginEndpoint),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      await SessionManager().saveToken(token); // ✅ Save in-memory and local storage
      return token;
    } else {
      final error = jsonDecode(response.body)["error"];
      throw Exception(error);
    }
  }

  Future<void> logout() async {
    await SessionManager().clearToken(); // ✅ Clear token from memory and storage
  }

  Future<String?> register(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.registerEndpoint),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      await _saveToken(token);
      return token;
    } else {
      final error = jsonDecode(response.body)["error"];
      throw Exception(error);
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

}
