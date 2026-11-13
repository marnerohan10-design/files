import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'loading_widget.dart';

/// Network image with caching, a shimmer placeholder and a fallback icon
/// for broken or missing URLs.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({super.key, required this.url, this.fit = BoxFit.contain});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    const fallback = Center(
      child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary, size: 32),
    );
    if (url.isEmpty) return fallback;

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, __) => const ShimmerBox(radius: 10),
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
