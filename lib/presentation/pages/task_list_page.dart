import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/common/custom_dropdown.dart';
import 'package:task_management/common/custom_text_field.dart';
import 'package:task_management/domain/task_model.dart';
import 'package:task_management/domain/user_model.dart';
import 'package:task_management/infrastructure/local/database_helper.dart';
import 'package:task_management/infrastructure/repositories/auth_repository.dart';
import 'package:task_management/presentation/bloc/task_bloc.dart';
import 'package:task_management/presentation/bloc/task_state.dart';
import 'package:task_management/presentation/pages/login_screen.dart';
import 'package:task_management/session/session_manager.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  void _showAddTaskDialog(BuildContext context, List<User> users) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();

    String? selectedPriority;
    String? selectedStatus;
    User? selectedUser;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Add Task",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(controller: titleController, label: "Title"),
                      CustomTextField(controller: descriptionController, label: "Description"),
                      CustomTextField(
                        controller: dueDateController,
                        label: "Due Date",
                        isReadOnly: true,
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.purpleAccent),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              dueDateController.text = pickedDate.toLocal().toString().split(' ')[0];
                            });
                          }
                        },
                      ),
                      CustomDropdown<String>(
                        label: "Priority",
                        value: selectedPriority,
                        items: const ["High", "Medium", "Low"],
                        onChanged: (value) => setState(() => selectedPriority = value),
                      ),
                      CustomDropdown<String>(
                        label: "Status",
                        value: selectedStatus,
                        items: const ["To-Do", "In Progress", "Done"],
                        onChanged: (value) => setState(() => selectedStatus = value),
                      ),
                      CustomDropdown<User>(
                        label: "Assigned User",
                        value: selectedUser,
                        items: users,
                        displayText: (user) => user.firstName,
                        onChanged: (value) => setState(() => selectedUser = value),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch,
                    userId: selectedUser!.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    dueDate: DateTime.parse(dueDateController.text),
                    priority: selectedPriority!,
                    status: selectedStatus!,
                    assignedUserId: selectedUser!.id,
                    completed: false,
                  );

                  await DatabaseHelper.instance.insertTask(newTask); // Save to SQLite
                  context.read<TaskBloc>().add(LoadTasks());

                  Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    TextEditingController taskController =
    TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Task",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    labelText: "Task Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (taskController.text.isNotEmpty) {
                          context.read<TaskBloc>().add(
                              UpdateTask(task.id, taskController.text, task.completed, task.userId));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Update"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logoutAndNavigateToLogin(BuildContext context) async {
    final authRepo = AuthRepository();
    await authRepo.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: const SizedBox(),
        leadingWidth: 30,titleSpacing: 40,
       title: const Text("Your Tasks",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_sharp,color: Colors.black,
          ),
          onPressed: () {
            SessionManager().clearToken();
            _logoutAndNavigateToLogin(context);
            },
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.tasks.isNotEmpty) {
          return ListView.builder(
            itemCount: state.tasks.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final task = state.tasks[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: task.completed ? Colors.green.shade100 : Colors.purpleAccent.withOpacity(0.2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            task.completed ? Icons.check_circle : Icons.pending,
                            color: task.completed ? Colors.green : Colors.purpleAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.completed ? "Completed" : "Pending",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: task.completed ? Colors.green : Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.black, size: 28),
                          onPressed: () => _showEditTaskDialog(context, task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_rounded, color: Colors.black, size: 28),
                          onPressed: () {
                            context.read<TaskBloc>().add(DeleteTask(task.id));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

        } else {
          return const Center(child: Text("No tasks found"));
        }
      }),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.black,
        onPressed: () async {
          final taskBloc = context.read<TaskBloc>();
          taskBloc.add(FetchUsers()); // Fetch users but keep tasks

          // await Future.delayed(Duration(milliseconds: 500));

          final currentState = taskBloc.state;
          if (currentState.users.isNotEmpty) {
            _showAddTaskDialog(context, currentState.users);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to load users. Try again.")),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
