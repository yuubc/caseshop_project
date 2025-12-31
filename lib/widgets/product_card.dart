import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  String _formatPrice(int price) {
    if (price == 0) {
      return '무료';
    }
    // 세 자리마다 콤마 추가
    final formatter = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formatter원';
  }

  Widget _buildProductImage() {
    // 1) 로컬 이미지가 있으면 파일로 표시
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      final file = File(product.imagePath!);
      return Image.file(
        file,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }

    // 2) 네트워크 이미지가 있으면 네트워크로 표시
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    // 3) 아무것도 없으면 placeholder
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.shopping_bag,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              // 상품 이미지 (왼쪽)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: _buildProductImage(),
                ),
              ),
              // 상품 정보 (오른쪽)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (product.description != null &&
                              product.description!.isNotEmpty)
                            Text(
                              product.description!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      Text(
                        _formatPrice(product.price),
                        style: TextStyle(
                          fontSize: 16,
                          color: product.price == 0
                              ? Colors.green[700]
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
