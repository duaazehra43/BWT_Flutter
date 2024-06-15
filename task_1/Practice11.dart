// Extend the Person class to create a Student class with additional properties like student ID and grade. Implement methods to display student details.

import 'Practice10.dart';

class Student extends Person {
  String studentId;
  String grade;

  Student(super.age, super.name, this.studentId, this.grade);

  void DisplayDetails() {
    print("Name: $name, Age: $age, Student Id: $studentId, Grade: $grade");
  }
}

void main() {
  Student student1 = new Student(21, "Duaa Zehra", "20SW043", "A");
  student1.DisplayDetails();
}
