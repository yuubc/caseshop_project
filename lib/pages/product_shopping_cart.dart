import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductShoppingCart extends StatefulWidget {
  final List<Product> cart;
  final Map<String, int> cartQuantities;

  const ProductShoppingCart({
    super.key,
    required this.cart,
    required this.cartQuantities,
  });

  @override
  State<ProductShoppingCart> createState() => _ProductShoppingCartState();
}

class _ProductShoppingCartState extends State<ProductShoppingCart> {
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    // cartQuantities에서 수량 가져오기
    quantities = widget.cart
        .map((product) => widget.cartQuantities[product.name] ?? 1)
        .toList();
  }

  // 금액 포맷 함수
  String _formatPrice(int price) {
    if (price == 0) {
      return '무료';
    }
    final formatter = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formatter원';
  }

  // 총 결제 금액 계산
  int get totalPrice {
    int sum = 0;
    for (int i = 0; i < widget.cart.length; i++) {
      sum += widget.cart[i].price * quantities[i];
    }
    return sum;
  }

  void _increaseQuantity(int index) {
    setState(() {
      if (quantities[index] < 99) {
        quantities[index]++;
        // cartQuantities도 업데이트
        widget.cartQuantities[widget.cart[index].name] = quantities[index];
      }
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (quantities[index] > 1) {
        quantities[index]--;
        // cartQuantities도 업데이트
        widget.cartQuantities[widget.cart[index].name] = quantities[index];
      }
    });
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('구매 확인'),
          content: Text(
            '총 ${_formatPrice(totalPrice)}을(를) 결제하시겠습니까?',
            style: const TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showPurchaseCompleteDialog();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('확인', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('구매 완료'),
          content: const Text('구매가 완료되었습니다!', style: TextStyle(fontSize: 16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // 장바구니 비우기
                widget.cart.clear();
                widget.cartQuantities.clear();
                quantities.clear();
                // dialog 닫기
                Navigator.of(context).pop();
                // 장바구니 페이지도 닫고 목록 페이지로 돌아가기
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('확인', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    // 1) 로컬 이미지
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      return Image.file(
        File(product.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    }

    // 2) 네트워크 이미지
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    }

    // 3) 기본
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.shopping_bag, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('장바구니'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: widget.cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '장바구니가 비었습니다.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: widget.cart.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final product = widget.cart[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 이미지
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: _buildProductImage(product),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 상품 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 수량 조절
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _decreaseQuantity(index),
                                      icon: const Icon(Icons.remove, size: 16),
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '${quantities[index]}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _increaseQuantity(index),
                                      icon: const Icon(Icons.add, size: 16),
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                              // 가격
                              Text(
                                _formatPrice(product.price * quantities[index]),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: widget.cart.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 결제 금액',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatPrice(totalPrice),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _showPurchaseDialog,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '구매하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
