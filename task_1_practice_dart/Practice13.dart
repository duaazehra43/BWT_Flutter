//Write a program that includes try-catch blocks to handle exceptions such as division by zero and invalid input.
import 'dart:io';

void main() {
  while (true) {
    try {
      print('\nEnter a numerator (enter "exit" to quit):');
      String input = stdin.readLineSync()!;

      if (input.toLowerCase() == 'exit') {
        exit(0);
      }

      int numerator = int.parse(input);

      print('Enter a denominator:');
      int denominator = int.parse(stdin.readLineSync()!);

      if (denominator == 0) {
        throw Exception('Division by zero is not allowed.');
      }

      double result = numerator / denominator;
      print('Result: $result');
    } catch (e) {
      print('Error: $e');
    }
  }
}
