// Create a function that checks if a given string is a palindrome (reads the same forwards and backwards).

bool isPalindrome(String str) {
  String cleanedStr = str.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();

  int len = cleanedStr.length;
  for (int i = 0; i < len ~/ 2; i++) {
    if (cleanedStr[i] != cleanedStr[len - i - 1]) {
      return false;
    }
  }
  return true;
}

void main() {
  List<String> testStrings = [
    "A man, a plan, a canal, Panama",
    "racecar",
    "hello",
    "Was it a car or a cat I saw?",
    "No 'x' in Nixon",
  ];

  for (String test in testStrings) {
    print('"$test" is ${isPalindrome(test) ? '' : 'not '}a palindrome.');
  }
}
