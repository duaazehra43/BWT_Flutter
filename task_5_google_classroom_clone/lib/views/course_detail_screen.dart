import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';
import 'package:task_5_google_classroom_clone/model/task_model.dart';
import 'package:task_5_google_classroom_clone/model/outline_model.dart';
import 'package:task_5_google_classroom_clone/service/course_service.dart';
import 'package:task_5_google_classroom_clone/view_model/course_detail_view_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  CourseDetailScreen(this.course);

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late CourseDetailViewModel _viewModel;
  late TabController _tabController;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  final CourseService _courseService = CourseService();

  @override
  void initState() {
    super.initState();
    _viewModel = CourseDetailViewModel(widget.course);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          widget.course.title,
          style: GoogleFonts.lato(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment),
            onPressed: () => _showAddCommentDialog(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.course.description,
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 10),
              TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: GoogleFonts.lato(),
                unselectedLabelStyle: GoogleFonts.lato(),
                controller: _tabController,
                tabs: [
                  Tab(
                    text: 'Tasks',
                  ),
                  Tab(text: 'Outline'),
                  Tab(text: 'Comments'),
                  Tab(text: 'Students'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksTab(),
          _buildOutlinesTab(),
          _buildCommentsTab(),
          _buildEnrolledStudentsTab(),
        ],
      ),
    );
  }

  void showEditOutlineDialog(BuildContext context, OutlineModel outline,
      CourseDetailViewModel viewModel) {
    TextEditingController _titleController =
        TextEditingController(text: outline.title);
    TextEditingController _descriptionController =
        TextEditingController(text: outline.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Edit Outline',
            style: GoogleFonts.lato(),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: GoogleFonts.lato(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.lato(),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(
                'Update',
                style: GoogleFonts.lato(),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white),
              onPressed: () {
                String title = _titleController.text.trim();
                String description = _descriptionController.text.trim();

                viewModel.updateOutline(outline.id, {
                  'title': title,
                  'description': description,
                }).then((_) {
                  Navigator.pop(
                      context); // Return to previous screen after update
                }).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to update outline: $error'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildCommentsList()),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _courseService.getComments(widget.course.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<DocumentSnapshot> comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return Center(child: Text('No comments yet.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            var comment = comments[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(comment['comment']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment['userEmail']),
                          SizedBox(height: 5),
                          _buildReplyField(comment.id), // Add reply field here
                        ],
                      ),
                      trailing: Text(
                        _formatTimestamp(comment['timestamp']),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    _buildRepliesList(widget.course.id, comment.id),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReplyField(String commentId) {
    TextEditingController _replyController = TextEditingController();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Reply to this comment...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String replyText = _replyController.text.trim();
              if (replyText.isNotEmpty) {
                _courseService.addCommentReply(
                  widget.course.id,
                  commentId,
                  replyText,
                );
                _replyController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesList(String courseId, String commentId) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _courseService.getCommentReplies(courseId, commentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox
              .shrink(); // Return empty container or loading indicator
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        List<DocumentSnapshot> replies = snapshot.data ?? [];

        if (replies.isEmpty) {
          return SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: ExpansionTile(
            title: Text('Replies (${replies.length})'),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  var reply = replies[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          child:
                              Text('T'), // Replace with user avatar or initials
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reply['userEmail'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(reply['reply']),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          _formatTimestamp(reply['timestamp']),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    return formattedTime;
  }

  void _showAddCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Add Comment',
            style: GoogleFonts.lato(),
          ),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(
                labelText: 'Enter your comment',
                labelStyle: GoogleFonts.lato(),
                border: OutlineInputBorder()),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _commentController.clear();
              },
            ),
            ElevatedButton(
              child: Text(
                'Add',
                style: GoogleFonts.lato(),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white),
              onPressed: () {
                _addComment();
                Navigator.of(context).pop();
                _commentController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void _addComment() {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      String userEmail = _auth.currentUser?.email ?? 'Unknown';
      _courseService
          .addComment(widget.course.id, userEmail, commentText)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment added successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $error')),
        );
      });
    }
  }

  Widget _buildDescriptionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course.description,
            style: GoogleFonts.lato(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledStudentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildEnrolledStudentsList()),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTasksList()),
        ],
      ),
    );
  }

  Widget _buildOutlinesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildOutlinesList()),
        ],
      ),
    );
  }

  Widget _buildEnrolledStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _viewModel.enrolledStudentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<DocumentSnapshot> studentDocs = snapshot.data!.docs;

        if (studentDocs.isEmpty) {
          return Center(child: Text('No students enrolled.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: studentDocs.length,
          itemBuilder: (context, index) {
            var student = studentDocs[index];
            return ListTile(
              key: Key(student.id), // Ensure each item has a unique key
              leading: CircleAvatar(
                child: Text(student['name'][0]),
              ),
              title: Text(student['name']),
              subtitle: Text(student['email']),
            );
          },
        );
      },
    );
  }

  Widget _buildTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _viewModel.tasksStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tasks assigned.'));
        }

        List<DocumentSnapshot> taskDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: taskDocs.length,
          itemBuilder: (context, index) {
            var task = TaskModel.fromSnapshot(taskDocs[index]);
            return Card(
              color: Colors.white,
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(task.description),
                    SizedBox(height: 5),
                    Text(
                      'Due Date: ${task.dueDate}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteTaskDialog(task),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editTask(task),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteTaskDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: GoogleFonts.lato(),
        ),
        content: Text(
          'Are you sure you want to delete this task?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteTask(task.id); // Call ViewModel method to delete
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, foregroundColor: Colors.white),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _viewModel.outlinesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No outlines available.'));
        }

        List<DocumentSnapshot> outlineDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: outlineDocs.length,
          itemBuilder: (context, index) {
            var outline = OutlineModel.fromSnapshot(outlineDocs[index]);
            return Card(
              color: Colors.white,
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(
                  outline.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(outline.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteOutlineDialog(outline),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          showEditOutlineDialog(context, outline, _viewModel),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editTask(TaskModel task) {
    TextEditingController titleController =
        TextEditingController(text: task.title);
    TextEditingController descriptionController =
        TextEditingController(text: task.description);
    DateTime? selectedDueDate = task.dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit Task', style: GoogleFonts.lato()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: GoogleFonts.lato(),
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.lato(),
                    border: OutlineInputBorder()),
                maxLines: null,
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDueDate(context, selectedDueDate),
                child: InputDecorator(
                  decoration: InputDecoration(
                      labelText: 'Due Date',
                      labelStyle: GoogleFonts.lato(),
                      border: OutlineInputBorder()),
                  child: Text(
                    selectedDueDate != null
                        ? "${selectedDueDate.toLocal()}".split(' ')[0]
                        : 'Select date',
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                String title = titleController.text.trim();
                String description = descriptionController.text.trim();
                if (selectedDueDate == null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Please select a due date.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                _viewModel.updateTask(task.id, {
                  'title': title,
                  'description': description,
                  'dueDate': selectedDueDate.toIso8601String(),
                }).then((_) {
                  Navigator.pop(context); // Close the edit dialog
                }).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to update task: $error'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _selectDueDate(BuildContext context, DateTime? selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showDeleteOutlineDialog(OutlineModel outline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Delete Outline',
          style: GoogleFonts.lato(),
        ),
        content: Text(
          'Are you sure you want to delete this outline?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel
                  .deleteOutline(outline.id); // Call ViewModel method to delete
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, foregroundColor: Colors.white),
            child: Text(
              'Delete',
              style: GoogleFonts.lato(),
            ),
          ),
        ],
      ),
    );
  }
}
