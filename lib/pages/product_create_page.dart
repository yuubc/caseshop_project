import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지를 선택하는 중 오류가 발생했습니다: $e')));
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text,
        price: int.parse(_priceController.text),
        imagePath: _imagePath, // 로컬 이미지 경로로 저장
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      Navigator.pop(context, product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 빈 영역 터치 시 키보드 숨기기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white, // 흰색 배경
        resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면 조정
        appBar: AppBar(
          title: const Text('상품 등록'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // 이미지 선택
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                  child: _imagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 60,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '이미지를 선택하세요',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // 상품명 입력
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  hintText: '상품명을 입력하세요',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '상품명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 가격 입력
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '가격',
                  hintText: '가격을 입력하세요',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '가격을 입력해주세요';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price < 0) {
                    return '올바른 가격을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 설명 입력
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '상품 설명 (선택)',
                  hintText: '상품 설명을 입력하세요',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 500,
              ),
              const SizedBox(height: 24),

              // 등록 버튼
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '상품 등록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // 키보드가 나타날 때를 위한 추가 여백
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
