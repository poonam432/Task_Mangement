class ApiConstants {
  static const String baseUrl = "https://reqres.in/api";
  static const String registerEndpoint = "$baseUrl/register";
  static const String loginEndpoint = "$baseUrl/login";
  static const String usersEndpoint = "$baseUrl/users";
  static const String tasksEndpoint = "https://jsonplaceholder.typicode.com/todos";
  static const String taskBaseUrl = "https://jsonplaceholder.typicode.com/todos";

  static const String getTasks = taskBaseUrl;
  static const String createTask = taskBaseUrl;
  static String updateTask(int id) => "$taskBaseUrl/$id";
  static String deleteTask(int id) => "$taskBaseUrl/$id";

}
