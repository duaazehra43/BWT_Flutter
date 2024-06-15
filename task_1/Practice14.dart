//Create a Dart class and write functions to serialize and deserialize JSON data. Use this to convert a list of objects to JSON and back.

import 'dart:convert';

class Person {
  String name;
  int age;

  Person(this.name, this.age);

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(json['name'], json['age']);
  }
}

void main() {
  Person person = Person('John', 30);
  String jsonStr = jsonEncode(person.toJson());
  print('JSON: $jsonStr');

  Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
  Person newPerson = Person.fromJson(jsonMap);
  print('Object: ${newPerson.name}, ${newPerson.age}');
}
