class Product {
  final String name;
  final int price;
  final String? imageUrl;
  final String? imagePath; // 로컬 이미지 경로 추가 (친구 코드와 호환)
  final String? description;

  const Product({
    required this.name,
    required this.price,
    this.imageUrl,
    this.imagePath,
    this.description,
  });

  Product copyWith({
    String? name,
    int? price,
    String? imageUrl,
    String? imagePath,
    String? description,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'description': description,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      price: json['price'] as int,
      imageUrl: json['imageUrl'] as String?,
      imagePath: json['imagePath'] as String?,
      description: json['description'] as String?,
    );
  }
}
