// Create a simple calculator that can perform addition, subtraction, multiplication, and division on two input numbers.
import 'dart:io';

void main() {
  print('Enter first number:');
  double num1 = double.parse(stdin.readLineSync()!);

  print('Enter an operator (+, -, *, /):');
  String operator = stdin.readLineSync()!;

  print('Enter second number:');
  double num2 = double.parse(stdin.readLineSync()!);

  double result;

  switch (operator) {
    case '+':
      result = add(num1, num2);
      break;
    case '-':
      result = subtract(num1, num2);
      break;
    case '*':
      result = multiply(num1, num2);
      break;
    case '/':
      if (num2 != 0) {
        result = divide(num1, num2);
      } else {
        print('Error: Division by zero');
        return;
      }
      break;
    default:
      print('Error: Invalid operator');
      return;
  }

  print('Result: $num1 $operator $num2 = $result');
}

double add(double a, double b) {
  return a + b;
}

double subtract(double a, double b) {
  return a - b;
}

double multiply(double a, double b) {
  return a * b;
}

double divide(double a, double b) {
  return a / b;
}
