import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  List<String> tasks = ["Buy groceries", "Complete project", "Workout"];
  List<bool> taskStatus = [false, true, false];
  List<String> taskDates = ["Tomorrow", "Next Week", "Today"];

  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

 void _addTask() {
    if (_taskController.text.isNotEmpty && _selectedDate != null) {
      setState(() {
        tasks.add(_taskController.text);
        taskStatus.add(false);
        taskDates.add(_formatDate(_selectedDate!));
        _taskController.clear();
        _selectedDate = null;
      });
      Navigator.of(context).pop();
    }
  }


  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(Duration(days: 1));

    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return "$formattedDate (Today)";
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
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
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Checkbox(
                value: taskStatus[index],
                onChanged: (bool? value) {
                  setState(() {
                    taskStatus[index] = value ?? false;
                  });
                },
              ),
              title: Text(
                tasks[index],
                style: TextStyle(
                  decoration: taskStatus[index]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text("Due: ${taskDates[index]}"),
              trailing: const Icon(Icons.edit),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
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
                          decoration: const InputDecoration(labelText: "Task Name"),
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
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed:_addTask,
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
