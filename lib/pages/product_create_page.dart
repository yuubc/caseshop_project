import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  String imageUrl = '';

  // =============================
  // 이미지 선택 BottomSheet
  // =============================
  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('로컬 이미지 선택'),
                onTap: pickImageFromGallery,
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('이미지 URL 입력'),
                onTap: showImageUrlDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  // =============================
  // 로컬 이미지 선택
  // =============================
  Future<void> pickImageFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        imageUrl = '';
      });
    }
    Navigator.pop(context);
  }

  // =============================
  // 이미지 URL 입력 Dialog
  // =============================
  void showImageUrlDialog() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('이미지 URL 입력'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                imageUrl = urlController.text;
                selectedImage = null;
              });
              Navigator.pop(context); // dialog
              Navigator.pop(context); // bottom sheet
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // =============================
  // 이미지 미리보기
  // =============================
  Widget buildImagePreview() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, height: 150);
    }

    if (imageUrl.isNotEmpty) {
      return Image.network(imageUrl, height: 150);
    }

    return const Text('이미지가 선택되지 않았습니다.');
  }

  // =============================
  // 등록 버튼 로직
  // =============================
  void onSave() {
    if (selectedImage == null && imageUrl.isEmpty ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('오류'),
          content: Text('모든 항목을 입력해주세요.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('등록 완료'),
        content: const Text('상품이 등록되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 이전 페이지로
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: showImagePickerOptions,
                child: const Text('이미지 선택'),
              ),
              const SizedBox(height: 8),
              buildImagePreview(),
              const SizedBox(height: 24),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '상품명'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: '상품 가격'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: '상품 설명'),
              ),
              const SizedBox(height: 32),

              ElevatedButton(onPressed: onSave, child: const Text('등록하기')),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../models/product.dart';

// class ProductCreatePage extends StatefulWidget {
//   const ProductCreatePage({super.key});

//   @override
//   State<ProductCreatePage> createState() => _ProductCreatePageState();
// }

// class _ProductCreatePageState extends State<ProductCreatePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   String? imageUrl;

//   void pickImage() {
//     // 과제용: 샘플 이미지 사용
//     setState(() {
//       imageUrl = 'https://picsum.photos/200/300';
//     });
//   }

//   void saveProduct() {
//     if (imageUrl == null ||
//         nameController.text.isEmpty ||
//         priceController.text.isEmpty ||
//         descriptionController.text.isEmpty) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text('입력 오류'),
//           content: const Text('모든 항목을 입력해주세요.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('확인'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     final int price = int.tryParse(priceController.text) ?? -1;

//     if (price < 0) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text('가격 오류'),
//           content: const Text('상품 가격은 숫자만 입력해주세요.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('확인'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     final product = Product(
//       name: nameController.text,
//       price: price,
//       imageUrl: imageUrl!,
//       description: descriptionController.text,
//     );

//     // 과제용: 실제 저장 대신 성공 팝업만 표시
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('등록 완료'),
//         content: const Text('상품이 성공적으로 등록되었습니다.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // 팝업 닫기
//               Navigator.pop(context, product); // 이전 페이지로 돌아가기
//             },
//             child: const Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Product')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // 이미지 선택 영역
//             GestureDetector(
//               onTap: pickImage,
//               child: Container(
//                 height: 180,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.grey.shade200,
//                 ),
//                 child: imageUrl == null
//                     ? const Center(child: Text('이미지 선택'))
//                     : ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.network(imageUrl!, fit: BoxFit.cover),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // 상품명
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: '상품명',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // 가격
//             TextField(
//               controller: priceController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: '가격',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // 상품 설명
//             TextField(
//               controller: descriptionController,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 labelText: '상품 설명',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 80),
//           ],
//         ),
//       ),

//       // 하단 고정 버튼
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: saveProduct,
//           child: const Text('등록하기'),
//         ),
//       ),
//     );
//   }
// }
