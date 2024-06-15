//Implement data structures like linked lists, stacks, and queues in Dart. Write functions to perform standard operations on these data structures.
class ListNode {
  int value;
  ListNode? next;

  ListNode(this.value);
}

class LinkedList {
  ListNode? _head;
  int _size = 0;

  int get size => _size;

  void add(int value) {
    ListNode newNode = ListNode(value);
    if (_head == null) {
      _head = newNode;
    } else {
      ListNode? current = _head;
      while (current!.next != null) {
        current = current.next;
      }
      current.next = newNode;
    }
    _size++;
  }

  bool remove(int value) {
    if (_head == null) return false;

    if (_head!.value == value) {
      _head = _head!.next;
      _size--;
      return true;
    }

    ListNode? current = _head;
    while (current!.next != null) {
      if (current.next!.value == value) {
        current.next = current.next!.next;
        _size--;
        return true;
      }
      current = current.next;
    }
    return false;
  }

  void display() {
    ListNode? current = _head;
    while (current != null) {
      print(current.value);
      current = current.next;
    }
  }
}

class Stack {
  List<int> _elements = [];

  void push(int value) {
    _elements.add(value);
  }

  int? pop() {
    if (_elements.isNotEmpty) {
      return _elements.removeLast();
    }
    return null;
  }

  int? peek() {
    if (_elements.isNotEmpty) {
      return _elements.last;
    }
    return null;
  }

  bool get isEmpty => _elements.isEmpty;

  int get size => _elements.length;
}

class Queue {
  List<int> _elements = [];

  void enqueue(int value) {
    _elements.add(value);
  }

  int? dequeue() {
    if (_elements.isNotEmpty) {
      return _elements.removeAt(0);
    }
    return null;
  }

  int? peek() {
    if (_elements.isNotEmpty) {
      return _elements.first;
    }
    return null;
  }

  bool get isEmpty => _elements.isEmpty;

  int get size => _elements.length;
}

void main() {
  LinkedList linkedList = LinkedList();
  linkedList.add(1);
  linkedList.add(2);
  linkedList.add(3);
  linkedList.display();
  linkedList.remove(2);
  linkedList.display();

  Stack stack = Stack();
  stack.push(1);
  stack.push(2);
  stack.push(3);
  print(stack.pop());
  print(stack.peek());

  Queue queue = Queue();
  queue.enqueue(1);
  queue.enqueue(2);
  queue.enqueue(3);
  print(queue.dequeue());
  print(queue.peek());
}
