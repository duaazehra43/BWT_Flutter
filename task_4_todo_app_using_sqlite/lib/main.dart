import 'package:flutter/material.dart';
import 'package:task_4_todo_app_using_sqlite/db_helper.dart';
import 'package:task_4_todo_app_using_sqlite/task.dart';
import 'package:task_4_todo_app_using_sqlite/taskform.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = getTasks();
  }

  Future<List<Task>> getTasks() async {
    final dbHelper = DBHelper();
    final taskMaps = await dbHelper.getTasks();
    return taskMaps.map((taskMap) => Task.fromMap(taskMap)).toList();
  }

  void refreshTasks() {
    setState(() {
      tasks = getTasks();
    });
  }

  void showTaskFormDialog(BuildContext context, {Task? task}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskFormDialog(task: task, onSave: refreshTasks);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Todo List',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Task>>(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final task = snapshot.data![index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: task.status == 'Completed'
                          ? [Colors.green[100]!, Colors.green[300]!]
                          : [Colors.red[100]!, Colors.red[300]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            task.status == 'Completed'
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: task.status == 'Completed'
                                ? Colors.green
                                : Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              task.status = task.status == 'Completed'
                                  ? 'Pending'
                                  : 'Completed';
                              DBHelper().updateTask(task.toMap());
                              refreshTasks();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey),
                          onPressed: () async {
                            await DBHelper().deleteTask(task.id!);
                            refreshTasks();
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      showTaskFormDialog(context, task: task);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTaskFormDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
