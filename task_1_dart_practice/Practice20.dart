//Composition

class Engine {
  void start() {
    print('Engine started');
  }
}

class Car {
  Engine _engine = Engine();

  void start() {
    _engine.start();
    print('Car started');
  }
}

void main() {
  Car car = Car();
  car.start();
}
