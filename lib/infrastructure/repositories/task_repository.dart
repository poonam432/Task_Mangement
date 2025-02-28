import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_management/domain/task_model.dart';
import 'package:task_management/domain/user_model.dart';
import 'package:task_management/network/api_endpoints.dart';

class TaskRepository {
  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse(ApiConstants.getTasks));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<Task> createTask(String title, int userId) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createTask),
      body: jsonEncode({
        "title": title,
        "completed": false,
        "userId": userId, // ✅ Required User ID
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create task");
    }
  }

  Future<Task> updateTask(int taskId, String title, bool completed, int userId) async {
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/todos/$taskId'),
      body: jsonEncode({
        "title": title,
        "completed": completed,
        'id':taskId,
        'userId':userId
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update task");
    }
  }


  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse(ApiConstants.deleteTask(id)));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete task");
    }
  }
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(ApiConstants.usersEndpoint));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> usersJson = data['data'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
