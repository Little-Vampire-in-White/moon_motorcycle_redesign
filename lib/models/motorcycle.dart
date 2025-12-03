class Motorcycle {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String engine;
  final String power;
  final String torque;

  Motorcycle({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.engine,
    required this.power,
    required this.torque,
  });

  factory Motorcycle.fromMap(String id, Map<String, dynamic> data) {
    double _parsePrice(dynamic price) {
      if (price is num) {
        return price.toDouble();
      }
      if (price is String) {
        return double.tryParse(price) ?? 0.0;
      }
      return 0.0;
    }

    return Motorcycle(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: _parsePrice(data['price']),
      imageUrl: data['imageUrl'] ?? '',
      engine: data['engine'] ?? '',
      power: data['power'] ?? '',
      torque: data['torque'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'engine': engine,
      'power': power,
      'torque': torque,
    };
  }
}
