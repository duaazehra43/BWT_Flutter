import 'dart:async';

Future<void> processStream<T>(
    Stream<T> stream, void Function(T event) callback) async {
  await for (final event in stream) {
    callback(event);
  }
}

Stream<int> countStream(int to) async* {
  for (int i = 1; i <= to; i++) {
    yield i;
  }
}

Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (final value in stream) {
    sum += value;
  }
  return sum;
}

void main() async {
  var stream = countStream(10);
  var broadcastStream = stream.asBroadcastStream();
  await processStream(broadcastStream, (event) => print(event));
}
