// Method Overriding
class Vehicle {
  void start() {
    print('Starting the vehicle');
  }
}

class Car extends Vehicle {
  @override
  void start() {
    print('Starting the car');
  }
}

void main() {
  Car car = Car();
  car.start();
}
