import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';

void main() {
  runApp(const MaterialApp(
    home: TaskManager(),
  ));
}

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  late List<String> tasks;
  late List<bool> taskStatus;
  List<String> taskDates = ["Tomorrow", "Next Week", "Today"];

  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_taskController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
      await DatabaseHelper().insertTask(
        _taskController.text,
        false,
        _formatDate(_selectedDate!),
        _selectedTime!.format(context).toString(),
      );
      _taskController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _loadTasks();
      Navigator.of(context).pop();
    } else {
      _showErrorDialog("Please enter both a task name and a due date.");
    }
  }

  Future<void> _updateTask(int id, String title, DateTime dueDate,
      TimeOfDay dueTime, bool isCompleted) async {
    if (title.isNotEmpty) {
      await DatabaseHelper().updateTask(
          id, title, _formatDate(dueDate), dueTime.toString(), isCompleted);
      _loadTasks();
      Navigator.of(context).pop();
    } else {
      _showErrorDialog("Please enter both a task name and a due date.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _loadTasks() async {
    final data = await DatabaseHelper().getTasks();
    setState(() {
      tasks = data.map((task) => task['title'].toString()).toList();
      taskStatus = data.map((task) => task['isCompleted'] == 1).toList();
      taskDates = data.map((task) => task['dueDate'].toString()).toList();
    });
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return "$formattedDate (Today)";
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return "$formattedDate (Tomorrow)";
    } else {
      return formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: DatabaseHelper().getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data as List<Map<String, dynamic>>;
          if (data.isEmpty) {
            return const Center(child: Text("No tasks available"));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final task = data[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: task['isCompleted'] == 1,
                    onChanged: (bool? value) async {
                      await DatabaseHelper()
                          .updateTaskStatus(task['id'], value ?? false);
                      _loadTasks();
                    },
                  ),
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      decoration: task['isCompleted'] == 1
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    "Due: ${task['dueDate']} ${task['dueTime']}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _taskController.text = task['title'];
                          _selectedDate =
                              DateFormat('dd-MM-yyyy').parse(task['dueDate']);
                          _selectedTime = task['dueTime'];

                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: const Text("Edit Task"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _taskController,
                                          decoration: const InputDecoration(
                                              labelText: "Task Name"),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedDate == null
                                                    ? "No Date Chosen"
                                                    : "Due: ${_formatDate(_selectedDate!)}",
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                _selectedDate = null;
                                                final DateTime? picked =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(2101),
                                                );
                                                if (picked != null) {
                                                  setState(() {
                                                    _selectedDate = picked;
                                                  });
                                                }
                                              },
                                              child: const Text("Choose Date"),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedTime == null
                                                    ? "No Time Chosen"
                                                    : "Due: ${_selectedTime!.format(context)}",
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                final pickedTime = await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );
                                                if (pickedTime != null) {
                                                  setState(() {
                                                    _selectedTime = pickedTime;
                                                  });
                                                }
                                              },
                                              child: const Text("Choose Time"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _updateTask(
                                              task['id'],
                                              _taskController.text,
                                              _selectedDate!,
                                              _selectedTime!,
                                              task['isCompleted'] == 1);
                                        },
                                        child: const Text("Update"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper().deleteTask(task['id']);
                          _loadTasks();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Add Task"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _taskController,
                          decoration:
                              const InputDecoration(labelText: "Task Name"),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? "No Date Chosen"
                                    : "Due: ${_formatDate(_selectedDate!)}",
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                              child: const Text("Choose Date"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedTime == null
                                    ? "No Time Chosen"
                                    : "Due: ${_selectedTime!.format(context)}",
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),

                                );
                                if (pickedTime != null) {
                                  setState(() {
                                    _selectedTime = pickedTime;
                                  });
                                }
                              },
                              child: const Text("Choose Time"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: _addTask,
                        child: const Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        tooltip: "Add Task",
        child: const Icon(Icons.add),
      ),
    );
  }
}
