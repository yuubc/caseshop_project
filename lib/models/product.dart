class Product {
  final String name;
  final int price;
  final String? imageUrl;
  final String? description;

  const Product({
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
  });

  Product copyWith({
    String? name,
    int? price,
    String? imageUrl,
    String? description,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  //추후 외부데이터 쓸때
  // factory Product.fromJson(Map<String, dynamic> json) {
  //   return Product(
  //     id: json['id'] as String,
  //     name: json['name'] as String,
  //     price: json['price'] as int,
  //     imageUrl: json['imageUrl'] as String?,
  //     description: json['description'] as String?,
  //   );
  // }
}
