import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../database/database_service.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialQuery;
  final bool? openFilter;
  const ExploreScreen({super.key, this.initialQuery, this.openFilter});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  List<String> _recentSearches = [];
  List<Product> _allProducts = [];
  List<Product> _results = [];
  bool _isSearching = false;

  double _minPrice = 0;
  double _maxPrice = 1000;
  String? _selectedCategory;
  List<String> _selectedColors = [];
  List<String> _selectedBrands = [];

  static const _categories = [
    {'label': 'Instant Cameras', 'color': 0xFF3B82F6, 'query': 'Instant Cameras'},
    {'label': 'DSLR', 'color': 0xFFFF6B6B, 'query': 'DSLR'},
    {'label': 'Mirrorless', 'color': 0xFF4ECDC4, 'query': 'Mirrorless'},
    {'label': 'Canon', 'color': 0xFFA855F7, 'query': 'Canon'},
    {'label': 'Nikon', 'color': 0xFFEAB308, 'query': 'Nikon'},
    {'label': 'Casio', 'color': 0xFFEF4444, 'query': 'Casio'},
    {'label': 'Panasonic', 'color': 0xFF16A34A, 'query': 'Panasonic'},
    {'label': 'Accessories', 'color': 0xFF6B7280, 'query': 'Accessories'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadRecentSearches();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!;
      _isSearching = true;
    }
    if (widget.openFilter == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showFilterSheet());
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadProducts() async {
    final products = await DatabaseService.instance.getAllProducts();
    if (mounted) {
      setState(() => _allProducts = products);
      if (_isSearching) _performSearch(_searchCtrl.text);
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('recent_searches');
    if (json != null && mounted) {
      setState(() => _recentSearches = List<String>.from(jsonDecode(json)));
    }
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) _recentSearches = _recentSearches.sublist(0, 10);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_searches', jsonEncode(_recentSearches));
    if (mounted) setState(() {});
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() { _isSearching = false; _results = []; });
      return;
    }
    _saveSearch(query);
    final q = query.toLowerCase();
    var filtered = _allProducts.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.brand.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q)
    ).toList();

    filtered = filtered.where((p) =>
      p.displayPrice >= _minPrice && p.displayPrice <= (_maxPrice == 1000 ? double.infinity : _maxPrice)
    ).toList();

    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    if (_selectedBrands.isNotEmpty) {
      filtered = filtered.where((p) => _selectedBrands.contains(p.brand)).toList();
    }

    setState(() { _isSearching = true; _results = filtered; });
  }

  bool get _hasActiveFilters =>
    _minPrice > 0 || _maxPrice < 1000 || _selectedCategory != null || _selectedColors.isNotEmpty || _selectedBrands.isNotEmpty;

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        selectedCategory: _selectedCategory,
        selectedColors: _selectedColors,
        selectedBrands: _selectedBrands,
        onApply: (min, max, cat, colors, brands) {
          setState(() {
            _minPrice = min; _maxPrice = max; _selectedCategory = cat;
            _selectedColors = colors; _selectedBrands = brands;
          });
          if (_isSearching) _performSearch(_searchCtrl.text);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explore 🔍', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: -0.3)),
                  const SizedBox(height: 12),
                  SearchBarWidget(
                    controller: _searchCtrl,
                    onSubmit: _performSearch,
                    onFilterPress: _showFilterSheet,
                    hasActiveFilters: _hasActiveFilters,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isSearching ? _buildResults() : _buildBrowse(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowse() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, AppResponsive.bottomInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('recent_searches');
                  setState(() => _recentSearches = []);
                },
                child: const Text('Clear', style: TextStyle(color: AppColors.coral)),
              ),
            ]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _recentSearches.map((s) => GestureDetector(
                onTap: () { _searchCtrl.text = s; _performSearch(s); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEED8E8), width: 1.5)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.history, size: 14, color: AppColors.inactive),
                    const SizedBox(width: 4),
                    Text(s, style: const TextStyle(fontSize: 13, color: AppColors.darkSecondary)),
                  ]),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.dark)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: AppResponsive.categoryColumns(context),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: _categories.map((cat) {
              final color = Color(cat['color'] as int);
              return GestureDetector(
                onTap: () { _searchCtrl.text = cat['query'] as String; _performSearch(cat['query'] as String); },
                child: Column(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.camera_alt_outlined, color: color, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(cat['label'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkSecondary)),
                ]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.inactive),
          const SizedBox(height: 16),
          Text('No results for "${_searchCtrl.text}"', style: const TextStyle(fontSize: 16, color: AppColors.textMid)),
        ]),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(AppResponsive.hp(context), AppResponsive.hp(context), AppResponsive.hp(context), AppResponsive.bottomInset(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppResponsive.gridColumns(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: AppResponsive.gridAspectRatio(context),
      ),
      itemCount: _results.length,
      itemBuilder: (context, i) => ProductCard(product: _results[i]),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final String? selectedCategory;
  final List<String> selectedColors;
  final List<String> selectedBrands;
  final Function(double, double, String?, List<String>, List<String>) onApply;

  const _FilterSheet({
    required this.minPrice, required this.maxPrice, required this.selectedCategory,
    required this.selectedColors, required this.selectedBrands, required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _min, _max;
  String? _category;
  late List<String> _colors, _brands;

  static const _allCategories = ['All', 'Instant Cameras', 'DSLR', 'Mirrorless', 'Accessories'];
  static const _allBrands = ['Canon', 'Nikon', 'Casio', 'Panasonic', 'Fujifilm', 'Sony'];

  @override
  void initState() {
    super.initState();
    _min = widget.minPrice; _max = widget.maxPrice;
    _category = widget.selectedCategory;
    _colors = List.from(widget.selectedColors);
    _brands = List.from(widget.selectedBrands);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () => setState(() { _min = 0; _max = 1000; _category = null; _colors = []; _brands = []; }),
                child: const Text('Reset', style: TextStyle(color: AppColors.coral)),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Category'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _allCategories.map((cat) {
                    final active = (cat == 'All' && _category == null) || cat == _category;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat == 'All' ? null : cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? AppColors.primary : const Color(0xFFEED8E8), width: 1.5),
                        ),
                        child: Text(cat, style: TextStyle(color: active ? Colors.white : AppColors.darkSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Price Range'),
                const SizedBox(height: 10),
                RangeSlider(
                  values: RangeValues(_min, _max),
                  min: 0, max: 1000,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primaryLight,
                  onChanged: (v) => setState(() { _min = v.start; _max = v.end; }),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$${_min.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('\$${_max.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 20),
                _sectionTitle('Color'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: AppColors.colorSwatches.entries.map((e) {
                    final selected = _colors.contains(e.key);
                    return GestureDetector(
                      onTap: () => setState(() { if (selected) _colors.remove(e.key); else _colors.add(e.key); }),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: e.value,
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5E7EB), width: selected ? 3 : 1),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                        ),
                        child: selected ? const Icon(Icons.check, size: 16, color: AppColors.primary) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Brand'),
                const SizedBox(height: 10),
                ..._allBrands.map((brand) {
                  final selected = _brands.contains(brand);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(brand, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
                    value: selected,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() { if (v == true) _brands.add(brand); else _brands.remove(brand); }),
                  );
                }),
                const SizedBox(height: 24),
              ]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => widget.onApply(_min, _max, _category, _colors, _brands),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Apply Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)));
}
