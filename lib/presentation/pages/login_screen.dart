import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/presentation/bloc/auth_bloc.dart';
import 'package:task_management/presentation/bloc/auth_event.dart';
import 'package:task_management/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateFields);
    passwordController.addListener(validateFields);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void validateFields() {
    setState(() {
      isButtonEnabled = emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.purpleAccent,
                behavior: SnackBarBehavior.floating,
                // ✅ Floating effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // ✅ Rounded edges
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                // ✅ Adds spacing
                elevation: 6,
                // ✅ Adds shadow
                duration: const Duration(seconds: 3),
              ));
            } else if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Login Successful!",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.purpleAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // ✅ Rounded edges
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 6,
                  duration: const Duration(seconds: 3),
                ),
              );
              Navigator.pushReplacementNamed(context, "/tasks");
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(34.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Manage Your team & everything with this Application ",
                      style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.w700,)),
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.person, color: Colors.black),
                      contentPadding: const EdgeInsets.all(0),
                      labelStyle: const TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                            width: 2.0), // Change to your desired color
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Passward',
                      prefixIcon: const Icon(Icons.lock_open_rounded,
                          color: Colors.black),
                      contentPadding: const EdgeInsets.all(0),
                      labelStyle: const TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                            width: 2.0), // Change to your desired color
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  if (state is AuthLoading) ...[
                    const CircularProgressIndicator(),
                  ] else ...[
                    TextButton(
                      onPressed: isButtonEnabled
                          ? () {
                              context.read<AuthBloc>().add(
                                    RegisterEvent(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    ),
                                  );
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Don't have an account?",
                              style: TextStyle(color: Colors.black45)),
                          Text(" Register",
                              style: TextStyle(color: Colors.purpleAccent)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: isButtonEnabled
                            ? () {
                                context.read<AuthBloc>().add(
                                      LoginEvent(
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                      ),
                                    );
                              }
                            : null,
                        child: const Text("Login"),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
