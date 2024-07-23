class Item {
  String imageUrl;
  String name;
  double price;
  String category;
  int quantity;

  Item({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.category,
    required this.quantity,
  });

  // Convert data to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'price': price,
      'category': category,
      'quantity': quantity,
    };
  }
}
