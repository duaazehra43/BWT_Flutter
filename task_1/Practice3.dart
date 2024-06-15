// Write a function that prints the first n numbers in the Fibonacci sequence.

import 'dart:io';

void main() {
  print("Enter any number where Fibonacci series end:  ");
  int num1 = int.parse(stdin.readLineSync()!);
  printFibonacci(num1);
}

void printFibonacci(int n) {
  int a = 0, b = 1, next;

  for (int i = 0; i < n; i++) {
    if (i <= 1) {
      next = i;
    } else {
      next = a + b;
      a = b;
      b = next;
    }
    print(next);
  }
}
