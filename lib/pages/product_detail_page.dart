import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Function(Product product, int quantity)? onAddToCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

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

  int get totalPrice => widget.product.price * quantity;

  void _increaseQuantity() {
    if (quantity < 99) {
      setState(() {
        quantity++;
      });
    }
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Widget _buildProductImage() {
    // 1) 로컬 이미지가 있으면 파일로 표시
    if (widget.product.imagePath != null &&
        widget.product.imagePath!.isNotEmpty) {
      final file = File(widget.product.imagePath!);
      return Image.file(
        file,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 100,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }

    // 2) 네트워크 이미지가 있으면 네트워크로 표시
    if (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty) {
      return Image.network(
        widget.product.imageUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 100,
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
          size: 100,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showAddToCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('장바구니'),
          content: Text(
            '${widget.product.name}을(를) $quantity개 장바구니에 담으시겠습니까?',
            style: const TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 장바구니에 추가
                if (widget.onAddToCart != null) {
                  widget.onAddToCart!(widget.product, quantity);
                }
                Navigator.of(context).pop();
                _showAddToCartCompleteDialog();
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

  void _showAddToCartCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('장바구니 담기 완료'),
          content: const Text(
            '장바구니에 상품이 담겼습니다!',
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
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

  void _showPurchaseConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('구매 확인'),
          content: Text(
            '${widget.product.name}을(를) $quantity개 구매하시겠습니까?',
            style: const TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 첫 번째 팝업 닫기
                _showPurchaseCompleteDialog(); // 구매 완료 팝업 표시
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
                Navigator.of(context).pop(); // 팝업 닫기
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

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('상품 삭제'),
          content: Text(
            '${widget.product.name}을(를) 삭제하시겠습니까?',
            style: const TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(true); // 상세 페이지 닫고 삭제 신호 전달
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('삭제', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 흰색 배경 설정
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // 뒤로가기
          },
        ),
        title: const Text('상품 상세'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // 삭제 버튼 (우측 상단)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmDialog,
            tooltip: '상품 삭제',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품 이미지 (큰 화면)
                  AspectRatio(
                    aspectRatio: 4 / 3, // 4:3 비율로 줄임 (이전: 1:1 정사각형)
                    child: _buildProductImage(),
                  ),
                  // 상품 정보
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상품명과 가격을 같은 줄에 표시
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatPrice(widget.product.price),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (widget.product.description != null &&
                            widget.product.description!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          //const Divider(),
                          const SizedBox(height: 24),
                          const Text(
                            '상품 설명',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.description!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                        const SizedBox(height: 80), // 하단 고정 영역을 위한 여백
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 하단 고정 영역: 수량 조절 + 총 가격 + 주문 버튼
      bottomNavigationBar: Container(
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
                // 첫 번째 줄: 수량 조절 + 총 가격
                Row(
                  children: [
                    // 수량 조절 버튼
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _decreaseQuantity,
                            icon: const Icon(Icons.remove),
                            color: quantity > 1 ? Colors.black87 : Colors.grey,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _increaseQuantity,
                            icon: const Icon(Icons.add),
                            color: quantity < 99 ? Colors.black87 : Colors.grey,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 총 가격
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '총 가격',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(totalPrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 두 번째 줄: 장바구니 담기 + 구매하기 버튼
                Row(
                  children: [
                    // 장바구니 담기 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showAddToCartDialog,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '장바구니',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 구매하기 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showPurchaseConfirmDialog,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '구매하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
