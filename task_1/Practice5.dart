// Write a function that checks if a given number is a prime number.

bool isPrime(int number) {
  if (number <= 1) {
    return false;
  }
  if (number <= 3) {
    return true;
  }
  if (number % 2 == 0 || number % 3 == 0) {
    return false;
  }

  for (int i = 5; i * i <= number; i += 6) {
    if (number % i == 0 || number % (i + 2) == 0) {
      return false;
    }
  }

  return true;
}

void main() {
  List<int> testNumbers = [1, 2, 3, 4, 5, 16, 17, 18, 19, 20];

  for (int number in testNumbers) {
    print('$number is ${isPrime(number) ? '' : 'not '}a prime number.');
  }
}
