//Create a program that takes two integers as input and prints their sum, difference, product, and quotient.

import 'dart:io';

void main() {
  print("Enter 1st number: ");
  var num1 = int.parse(stdin.readLineSync()!);

  print("Enter 2nd number: ");
  var num2 = int.parse(stdin.readLineSync()!);

  int sum = num1 + num2;
  int dif = num1 - num2;
  int mult = num1 * num2;
  double div = num1 / num2;

  print("Sum:  $sum");
  print("Differnce:  $dif");
  print("Multiplication: $mult");
  print("Division:  $div");
}
