import 'package:flutter/material.dart';
import 'package:task_4_todo_app_using_sqlite/db_helper.dart';
import 'package:task_4_todo_app_using_sqlite/task.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? task;
  final VoidCallback onSave;

  TaskFormDialog({this.task, required this.onSave});

  @override
  _TaskFormDialogState createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _status = widget.task!.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: widget.task?.title ?? '',
              decoration: InputDecoration(labelText: 'Title'),
              onSaved: (value) {
                _title = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: widget.task?.description ?? '',
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (value) {
                _description = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Pending', 'Completed'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Task task = Task(
                id: widget.task?.id,
                title: _title,
                description: _description,
                status: _status,
              );
              if (widget.task == null) {
                await DBHelper().insertTask(task.toMap());
              } else {
                await DBHelper().updateTask(task.toMap());
              }
              widget.onSave();
              Navigator.pop(context);
            }
          },
          child: Text(widget.task == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
