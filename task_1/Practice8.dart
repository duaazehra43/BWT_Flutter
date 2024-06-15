/* Write functions to:
     Count the number of vowels and consonants in a string.
     Reverse a string.
     Convert a string to uppercase and lowercase. */

void main() {
  String str = "Duaa Zehra";
  var count = countVowelsAndConsonants(str);
  print('Vowels: ${count['vowels']}, Consonants: ${count['consonants']}');
  print('Reversed: ${reverseString(str)}');
  print('Uppercase: ${toUpperCase(str)}');
  print('Lowercase: ${toLowerCase(str)}');
}

Map<String, int> countVowelsAndConsonants(String str) {
  int vowels = 0;
  int consonants = 0;
  String vowelsSet = 'aeiouAEIOU';

  for (int i = 0; i < str.length; i++) {
    if (RegExp(r'[a-zA-Z]').hasMatch(str[i])) {
      if (vowelsSet.contains(str[i])) {
        vowels++;
      } else {
        consonants++;
      }
    }
  }

  return {'vowels': vowels, 'consonants': consonants};
}

String reverseString(String str) {
  return str.split('').reversed.join('');
}

String toUpperCase(String str) {
  return str.toUpperCase();
}

String toLowerCase(String str) {
  return str.toLowerCase();
}
