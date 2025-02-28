import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:task_management/infrastructure/repositories/auth_repository.dart';
import 'package:task_management/infrastructure/repositories/task_repository.dart';
import 'package:task_management/presentation/bloc/auth_bloc.dart';
import 'package:task_management/presentation/bloc/task_bloc.dart';
import 'package:task_management/presentation/pages/login_screen.dart';
import 'package:task_management/presentation/pages/task_list_page.dart';
import 'package:task_management/domain/user_model.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(AppLoader()); 
  }


class AppLoader extends StatefulWidget {
  @override
  _AppLoaderState createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  late Future<Map<String, dynamic>> _initApp;

  @override
  void initState() {
    super.initState();
    _initApp = _loadAppData();
  }

  Future<Map<String, dynamic>> _loadAppData() async {
    final authRepository = AuthRepository();
    final taskRepository = TaskRepository();

    final token = await authRepository.getToken();
    final isLoggedIn = token != null;

    List<User> users = [];
    if (isLoggedIn) {
      users = await taskRepository.fetchUsers(); 
    }

    return {"isLoggedIn": isLoggedIn, "users": users};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initApp,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        final isLoggedIn = snapshot.data!["isLoggedIn"] as bool;
        final users = snapshot.data!["users"] as List<User>;

        return MyApp(isLoggedIn: isLoggedIn, users: users);
      },
    );
  }
}
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final List<User> users;

  MyApp({required this.isLoggedIn, required this.users});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(AuthRepository())),
        BlocProvider(create: (context) => TaskBloc(TaskRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Management',
        initialRoute: isLoggedIn ? '/tasks' : '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/tasks': (context) => TaskScreen(),
        },
      ),
    );
  }
}
