import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dio}) : dio = dio ?? Dio(BaseOptions(baseUrl: "https://reqres.in/api/"));

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await dio.post(path, data: data);
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  Future<Response> get(String path) async {
    try {
      return await dio.get(path);
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
