import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'product_create_page.dart';
import 'product_shopping_cart.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // 임시 상품 데이터
  List<Product> products = [
    const Product(
      name: '아이폰 15 Pro 케이스',
      price: 35000,
      imageUrl: 'https://picsum.photos/300/300?random=1',
      description: '고급스러운 가죽 케이스',
    ),
    const Product(
      name: '갤럭시 S24 케이스',
      price: 25000,
      imageUrl: 'https://picsum.photos/300/300?random=2',
      description: '튼튼한 실리콘 케이스',
    ),
    const Product(
      name: '맥북 프로 파우치',
      price: 0,
      imageUrl: 'https://picsum.photos/300/300?random=3',
      description: '무료 증정 이벤트',
    ),
    const Product(
      name: '에어팟 케이스',
      price: 15000,
      imageUrl: 'https://picsum.photos/300/300?random=4',
      description: '귀여운 캐릭터 디자인',
    ),
    const Product(
      name: '아이패드 커버',
      price: 45000,
      imageUrl: 'https://picsum.photos/300/300?random=5',
      description: '스탠드 기능 포함',
    ),
  ];

  // 장바구니 리스트 (상품과 수량을 함께 관리)
  final List<Product> cart = [];
  final Map<String, int> cartQuantities = {}; // 상품명: 수량

  void _addToCart(Product product, int quantity) {
    setState(() {
      // 이미 장바구니에 있는 상품인지 확인
      if (cartQuantities.containsKey(product.name)) {
        // 이미 있으면 수량만 증가
        cartQuantities[product.name] = cartQuantities[product.name]! + quantity;
      } else {
        // 없으면 새로 추가
        cart.add(product);
        cartQuantities[product.name] = quantity;
      }
    });
  }

  void _navigateToDetail(Product product, int index) async {
    final shouldDelete = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailPage(product: product, onAddToCart: _addToCart),
      ),
    );

    // 상품 상세 페이지에서 삭제를 선택한 경우
    if (shouldDelete == true) {
      setState(() {
        products.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name}이(가) 삭제되었습니다.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductCreatePage()),
    );

    // 상품 등록 페이지에서 돌아올 때 새 상품이 있으면 추가
    if (result != null && result is Product) {
      setState(() {
        products.add(result);
      });
    }
  }

  void _navigateToCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductShoppingCart(cart: cart, cartQuantities: cartQuantities),
      ),
    );
    // 장바구니에서 돌아왔을 때 화면 새로고침
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            const Text(
              'CaseShop',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // 장바구니 아이콘
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _navigateToCart,
                tooltip: '장바구니',
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartQuantities.values.fold(0, (sum, qty) => sum + qty)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: products.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '상품이 없습니다.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '하단의 + 버튼을 눌러 상품을 등록해보세요.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProductCard(
                      product: product,
                      onTap: () => _navigateToDetail(product, index),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        tooltip: '상품 등록',
        child: const Icon(Icons.add),
      ),
    );
  }
}
