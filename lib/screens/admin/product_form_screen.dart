import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/database_service.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_utils.dart';

class ProductFormScreen extends StatefulWidget {
  final String productId;
  const ProductFormScreen({super.key, required this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  bool get isNew => widget.productId == 'new';
  Product? _product;

  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Instant Cameras';
  String? _imageUrl;
  bool _isLoading = false;

  static const _categories = ['Instant Cameras', 'DSLR', 'Mirrorless', 'Accessories'];

  @override
  void initState() {
    super.initState();
    if (!isNew) _loadProduct();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _brandCtrl.dispose(); _priceCtrl.dispose();
    _salePriceCtrl.dispose(); _stockCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final p = await DatabaseService.instance.getProductById(int.parse(widget.productId));
    if (p != null && mounted) {
      setState(() {
        _product = p;
        _nameCtrl.text = p.name;
        _brandCtrl.text = p.brand;
        _priceCtrl.text = p.price.toString();
        _salePriceCtrl.text = p.salePrice?.toString() ?? '';
        _stockCtrl.text = p.stock.toString();
        _descCtrl.text = p.description;
        _category = _categories.contains(p.category) ? p.category : _categories.first;
        _imageUrl = p.imageUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) setState(() => _imageUrl = image.path);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and price are required')));
      return;
    }
    setState(() => _isLoading = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'brand': _brandCtrl.text.trim(),
      'category': _category,
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text) ?? 0,
      'sale_price': _salePriceCtrl.text.isNotEmpty ? double.tryParse(_salePriceCtrl.text) : null,
      'stock': int.tryParse(_stockCtrl.text) ?? 0,
      'image_url': _imageUrl ?? '',
      'is_active': 1,
    };
    try {
      if (isNew) {
        await DatabaseService.instance.addProduct(data);
      } else {
        await DatabaseService.instance.updateProduct(_product!.id, data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isNew ? 'Product added!' : 'Product updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isNew ? 'Add Product' : 'Edit Product', style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: _imageUrl != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: ImageUtils.productImage(_imageUrl, fit: BoxFit.cover))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 48, color: Color(0xFF9CA3AF)),
                        SizedBox(height: 8),
                        Text('Tap to add image', style: TextStyle(color: Color(0xFF9CA3AF))),
                      ]),
              ),
            ),
            const SizedBox(height: 20),
            _label('Product Name *'),
            const SizedBox(height: 8),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Canon PowerShot...')),
            const SizedBox(height: 16),
            _label('Brand'),
            const SizedBox(height: 8),
            TextField(controller: _brandCtrl, decoration: const InputDecoration(hintText: 'Canon')),
            const SizedBox(height: 16),
            _label('Category'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) { if (v != null) setState(() => _category = v); },
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Price *'),
                const SizedBox(height: 8),
                TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '\$')),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Sale Price'),
                const SizedBox(height: 8),
                TextField(controller: _salePriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '\$', hintText: 'Optional')),
              ])),
            ]),
            const SizedBox(height: 16),
            _label('Stock'),
            const SizedBox(height: 8),
            TextField(controller: _stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '0')),
            const SizedBox(height: 16),
            _label('Description'),
            const SizedBox(height: 8),
            TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Product description...')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isNew ? 'Add Product' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)));
}
