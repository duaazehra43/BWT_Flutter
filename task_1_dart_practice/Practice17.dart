// Encapsulation

class BankAccount {
  int _balance = 0;

  void deposit(int amount) {
    _balance += amount;
  }

  void withdraw(int amount) {
    if (amount <= _balance) {
      _balance -= amount;
    } else {
      print('Insufficient funds!');
    }
  }

  int get balance {
    return _balance;
  }
}

void main() {
  BankAccount account = BankAccount();
  account.deposit(1000);
  account.withdraw(500);
  print('Current balance: ${account.balance}');
}
