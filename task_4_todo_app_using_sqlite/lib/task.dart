class Task {
  int? id;
  String title;
  String description;
  String status;

  Task(
      {this.id,
      required this.title,
      required this.description,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
    );
  }
}
