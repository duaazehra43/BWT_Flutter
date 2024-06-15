// Write a program to read from and write to a text file. The program should take input from the user and save it to a file, then read the contents of the file and display it.

import 'dart:io';

void main() {
  while (true) {
    print('\nEnter your choice:');
    print('1. Write to file');
    print('2. Read from file');
    print('3. Exit');

    String choice = stdin.readLineSync()!;

    switch (choice) {
      case '1':
        writeToFile();
        break;
      case '2':
        readFromFile();
        break;
      case '3':
        exit(0);
      default:
        print('Invalid choice. Please enter 1, 2, or 3.');
    }
  }
}

void writeToFile() {
  print('Enter text to write to file:');
  String inputText = stdin.readLineSync()!;

  String fileName = 'user_input.txt';
  File file = File(fileName);
  file.writeAsStringSync(inputText);

  print('Input saved to $fileName');
}

void readFromFile() {
  String fileName = 'user_input.txt';
  File file = File(fileName);

  if (!file.existsSync()) {
    print('File $fileName does not exist.');
    return;
  }

  print('\nReading from file $fileName:');
  String fileContents = file.readAsStringSync();
  print('Contents of $fileName:');
  print(fileContents);
}
