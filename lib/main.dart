import 'package:flutter/material.dart';

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
              subtitle: const Text("Due: Tomorrow"),
              trailing: const Icon(Icons.edit),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add task functionality to be implemented
        },
        child: Icon(Icons.add),
        tooltip: "Add Task",
      ),
    );
  }
}
