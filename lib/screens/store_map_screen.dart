import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/database_service.dart';
import '../models/store_location.dart';
import '../theme/app_theme.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  final _mapController = MapController();
  List<StoreLocation> _stores = [];
  StoreLocation? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    final stores = await DatabaseService.instance.getAllStores();
    if (mounted) {
      setState(() {
        _stores = stores;
        _selected = stores.isNotEmpty ? stores.first : null;
        _loading = false;
      });
    }
  }

  void _focusStore(StoreLocation store) {
    setState(() => _selected = store);
    _mapController.move(LatLng(store.latitude, store.longitude), 14);
  }

  Future<void> _openDirections(StoreLocation store) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${store.latitude},${store.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callStore(StoreLocation store) async {
    final uri = Uri.parse('tel:${store.phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Store Locations', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stores.isEmpty
              ? const Center(child: Text('No store locations available'))
              : Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(_selected!.latitude, _selected!.longitude),
                          initialZoom: 5.5,
                          minZoom: 4,
                          maxZoom: 18,
                          onTap: (_, __) => setState(() {}),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.popishop.popishop_flutter',
                          ),
                          MarkerLayer(
                            markers: _stores.map((store) {
                              final isSelected = _selected?.id == store.id;
                              return Marker(
                                point: LatLng(store.latitude, store.longitude),
                                width: 48,
                                height: 48,
                                child: GestureDetector(
                                  onTap: () => _focusStore(store),
                                  child: Icon(
                                    Icons.location_on,
                                    size: isSelected ? 44 : 36,
                                    color: isSelected ? AppColors.primary : AppColors.red,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    _buildStorePanel(),
                  ],
                ),
    );
  }

  Widget _buildStorePanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
          ),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              itemCount: _stores.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final store = _stores[i];
                final selected = _selected?.id == store.id;
                return GestureDetector(
                  onTap: () => _focusStore(store),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: 0.08) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? AppColors.primary : const Color(0xFF111827))),
                        const SizedBox(height: 4),
                        Text(store.address, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selected != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selected!.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(_selected!.address, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(_selected!.hours, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(_selected!.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _callStore(_selected!),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openDirections(_selected!),
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text('Directions'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
