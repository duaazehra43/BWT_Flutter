// Create a Person class with properties like name, age, and methods to display the person's details. Create objects of this class and display their details.

class Person {
  String name;
  int age;

  Person(this.age, this.name);

  void displayDetails() {
    print('Name: $name, Age: $age');
  }
}

void main() {
  Person person1 = new Person(21, "Duaa Zehra");
  person1.displayDetails();
}
