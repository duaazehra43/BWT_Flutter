/* Create a list of integers and write functions to:
      Find the largest and smallest numbers in the list.
      Calculate the sum and average of the numbers.
      Sort the list in ascending and descending order. */

void main() {
  List<int> numbers = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5];

  print('Numbers: $numbers');
  print('Largest number: ${findLargest(numbers)}');
  print('Smallest number: ${findSmallest(numbers)}');
  print('Sum: ${calculateSum(numbers)}');
  print('Average: ${calculateAverage(numbers)}');
  print('Sorted in ascending order: ${sortAscending(numbers)}');
  print('Sorted in descending order: ${sortDescending(numbers)}');
}

int findLargest(List<int> numbers) {
  int largest = numbers[0];
  for (int num in numbers) {
    if (num > largest) {
      largest = num;
    }
  }
  return largest;
}

int findSmallest(List<int> numbers) {
  int smallest = numbers[0];
  for (int num in numbers) {
    if (num < smallest) {
      smallest = num;
    }
  }
  return smallest;
}

int calculateSum(List<int> numbers) {
  int sum = 0;
  for (int num in numbers) {
    sum += num;
  }
  return sum;
}

double calculateAverage(List<int> numbers) {
  return calculateSum(numbers) / numbers.length;
}

List<int> sortAscending(List<int> numbers) {
  List<int> sortedList = List.from(numbers);
  sortedList.sort();
  return sortedList;
}

List<int> sortDescending(List<int> numbers) {
  List<int> sortedList = List.from(numbers);
  sortedList.sort((a, b) => b.compareTo(a));
  return sortedList;
}
