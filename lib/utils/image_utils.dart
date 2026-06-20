import 'package:flutter/material.dart';

class ImageUtils {
  static const Map<String, String> _imageMap = {
    'CanonIXY.jpg': 'assets/images/CanonIXY.jpg',
    'CanonIXY620F.jpg': 'assets/images/CanonIXY620F.jpg',
    'CanonPowershot.jpg': 'assets/images/CanonPowershot.jpg',
    'CasioExilim.jpg': 'assets/images/CasioExilim.jpg',
    'NikonCoolpixA100.jpg': 'assets/images/NikonCoolpixA100.jpg',
    'PanasonicLumix.jpg': 'assets/images/PanasonicLumix.jpg',
    'fujifilm.png': 'assets/images/fujifilm.png',
    'SonyDSC.png': 'assets/images/SonyDSC.png',
    'logo.png': 'assets/images/logo.png',
    'icon.png': 'assets/images/icon.png',
  };

  static ImageProvider getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/images/icon.png');
    }
    if (imageUrl.startsWith('http') || imageUrl.startsWith('file://')) {
      return NetworkImage(imageUrl);
    }
    final asset = _imageMap[imageUrl];
    if (asset != null) {
      return AssetImage(asset);
    }
    return const AssetImage('assets/images/icon.png');
  }

  static Widget productImage(String? imageUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (imageUrl != null && (imageUrl.startsWith('http') || imageUrl.startsWith('file://'))) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(width, height),
      );
    }
    final asset = imageUrl != null ? _imageMap[imageUrl] : null;
    if (asset != null) {
      return Image.asset(asset, width: width, height: height, fit: fit);
    }
    return _placeholder(width, height);
  }

  static Widget _placeholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3F4F6),
      child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF9CA3AF), size: 40),
    );
  }
}
