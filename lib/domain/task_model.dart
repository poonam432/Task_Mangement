class Task {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? priority; // High, Medium, Low
  final String? status; // To-Do, In Progress, Done
  final int? assignedUserId;
  final bool completed;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.status,
    this.assignedUserId,
    required this.completed,
  });

  /// Convert JSON to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null, // ✅ Convert String to DateTime
      priority: json['priority'],
      status: json['status'],
      assignedUserId: json['assignedUserId'],
      completed: (json['completed'] is int) ? json['completed'] == 1 : json['completed'] == true,
    );
  }

  /// Convert Task object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "description": description,
      "dueDate": dueDate?.toIso8601String(),
      "priority": priority,
      "status": status,
      "assignedUserId": assignedUserId,
      'completed': completed ? 1 : 0,
    };
  }
}
