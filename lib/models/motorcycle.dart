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

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
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
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _parsePrice(json['price']),
      imageUrl: json['imageUrl'] ?? '',
      engine: json['engine'] ?? '',
      power: json['power'] ?? '',
      torque: json['torque'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
