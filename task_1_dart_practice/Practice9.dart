// Write a function that calculates the factorial of a given number.
import 'dart:io';

void main() {
  print("Enter any number: ");
  int num1 = int.parse(stdin.readLineSync()!);
  print(calculateFactorial(num1));
}

int calculateFactorial(int number) {
  if (number < 0) {
    throw ArgumentError('Number must be non-negative.');
  }
  if (number == 0 || number == 1) {
    return 1;
  }
  int factorial = 1;
  for (int i = 2; i <= number; i++) {
    factorial *= i;
  }
  return factorial;
}
