import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  void increaseQuantity() {
    if (quantity < 99) {
      setState(() {
        quantity++;
      });
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  int get totalPrice => widget.product.price * quantity;

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        ) +
        '원';
  }

  void showOrderConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('구매 확인'),
        content: Text('${widget.product.name}을(를) $quantity개 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showOrderCompleteDialog();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void showOrderCompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('구매 완료'),
        content: const Text('구매가 완료되었습니다.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // 상품명
            Text(
              product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // 상품 설명
            Text(product.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 24),

            // 수량 조절
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('구매 수량', style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    IconButton(
                      onPressed: decreaseQuantity,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: increaseQuantity,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 32),

            // 총 가격
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('총 가격', style: TextStyle(fontSize: 18)),
                Text(
                  formatPrice(totalPrice),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 구매 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: showOrderConfirmDialog,
                child: const Text('구매하기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
