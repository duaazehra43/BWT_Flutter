import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';
import 'package:task_5_google_classroom_clone/model/outline_model.dart';
import 'package:task_5_google_classroom_clone/model/task_model.dart';
import 'package:task_5_google_classroom_clone/service/course_service.dart';
import 'package:task_5_google_classroom_clone/views/submit_task_screen.dart';
import 'package:task_5_google_classroom_clone/view_model/course_detail_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CourseDetailStudentScreen extends StatefulWidget {
  final CourseModel course;

  CourseDetailStudentScreen(this.course);

  @override
  State<CourseDetailStudentScreen> createState() =>
      _CourseDetailStudentScreenState();
}

class _CourseDetailStudentScreenState extends State<CourseDetailStudentScreen>
    with SingleTickerProviderStateMixin {
  late CourseDetailViewModel _viewModel;
  late TabController _tabController;
  final CourseService _courseService = CourseService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

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
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _commentController.clear();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white),
              child: Text(
                'Add',
                style: GoogleFonts.lato(),
              ),
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
                          _buildReplyField(comment.id),
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

  void _addComment() {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      String userEmail = _auth.currentUser?.email ?? 'Unknown';
      _courseService
          .addComment(widget.course.id, userEmail, commentText)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.purple,
              content: Text(
                'Comment added successfully',
                style: GoogleFonts.lato(color: Colors.white),
              )),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $error')),
        );
      });
    }
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

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No students enrolled.'));
        }

        List<DocumentSnapshot> studentDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: studentDocs.length,
          itemBuilder: (context, index) {
            var student = studentDocs[index];
            return ListTile(
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
                trailing: task.fileUrl != null
                    ? IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () => _downloadFile(task.fileUrl!),
                      )
                    : Icon(Icons.insert_drive_file),
                subtitle: task.submittedBy != null
                    ? Text('Submitted by: ${task.submittedBy}')
                    : null,
                onTap: () => _navigateToSubmitTaskScreen(context, task),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToSubmitTaskScreen(BuildContext context, TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitTaskScreen(task),
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
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String filePath = '${appDocDir.path}/${url.split('/').last}';
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Downloaded to $filePath',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.purple,
          ),
        );
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
