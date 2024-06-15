//Write a function that checks whether a given integer is even or odd.

import 'dart:io';

void main() {
  print("Enter any number: ");
  int num1 = int.parse(stdin.readLineSync()!);

  if (num1 % 2 == 0) {
    print("It is a even number.");
  } else {
    print("It is a odd number");
  }
}
