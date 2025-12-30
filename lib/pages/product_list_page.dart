import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_create_page.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<Product> products = [];

  String formatPrice(int price) {
    if (price == 0) return '무료';
    return price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        ) +
        '원';
  }

  Future<void> goToCreatePage() async {
    final Product? newProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductCreatePage()),
    );

    if (newProduct != null) {
      setState(() {
        products.add(newProduct);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Case Shop')),
      body: products.isEmpty
          ? const Center(child: Text('상품이 없습니다.'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(formatPrice(product.price)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToCreatePage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
