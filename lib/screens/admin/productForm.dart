import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/language_service.dart';
import '../../services/productService.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> with LanguageStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _shopIdController;
  late TextEditingController _sectionController;
  String _selectedCategory = 'flowers';

  final List<String> _categories = ['flowers', 'bouquets', 'gifts', 'plants'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _priceController = TextEditingController(text: widget.product?.price.toString());
    _descriptionController = TextEditingController(text: widget.product?.description);
    _imageController = TextEditingController(text: widget.product?.images.join(', '));
    _shopIdController = TextEditingController(text: widget.product?.shopId);
    _sectionController = TextEditingController(text: widget.product?.section ?? 'flowers');
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _shopIdController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final t = getTranslations();
    final images = _imageController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text,
      price: int.parse(_priceController.text),
      description: _descriptionController.text,
      images: images,
      shopId: _shopIdController.text,
      category: _selectedCategory,
      section: _sectionController.text,
      rating: widget.product?.rating ?? 5.0,
      reviews: widget.product?.reviews ?? 0,
    );

    bool success;
    if (widget.product == null) {
      final id = await _productService.createProduct(product);
      success = id != null;
    } else {
      success = await _productService.updateProduct(product);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product == null ? t('add_product') : t('edit_product'),
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(t('save'), style: const TextStyle(color: Color(0xFFB07183), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTextField(_nameController, t('name'), validator: (v) => v!.isEmpty ? t('field_required') : null),
            const SizedBox(height: 16),
            _buildTextField(_priceController, t('price'), keyboardType: TextInputType.number, validator: (v) => int.tryParse(v ?? '') == null ? t('invalid_price') : null),
            const SizedBox(height: 16),
            _buildDropdown(t('category')),
            const SizedBox(height: 16),
            _buildTextField(_sectionController, 'Section (e.g. flowers, monobouquets)', validator: (v) => v!.isEmpty ? t('field_required') : null),
            const SizedBox(height: 16),
            _buildTextField(_shopIdController, 'Shop ID', validator: (v) => v!.isEmpty ? t('field_required') : null),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, t('description'), maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(_imageController, t('images_hint')),
            const SizedBox(height: 8),
            Text(t('images_desc'), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
      onChanged: (v) => setState(() => _selectedCategory = v!),
    );
  }
}
