import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Widget pemuat poster film yang seragam untuk semua halaman.
///
/// Perilaku:
/// - Web: memakai `Image.network` dengan `WebHtmlElementStrategy.fallback`
///   supaya gambar tetap termuat walau server belum mengirim header CORS.
/// - Native (Android/iOS/desktop): memakai `CachedNetworkImage` agar poster
///   di-cache di perangkat.
/// - URL kosong / gagal dimuat: tampilkan placeholder, bukan gambar rusak.
class PosterImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const PosterImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final Widget fallback = placeholder ?? const PosterPlaceholder();

    final String? target = url;
    if (target == null || target.isEmpty) {
      return SizedBox(width: width, height: height, child: fallback);
    }

    if (kIsWeb) {
      return Image.network(
        target,
        fit: fit,
        width: width,
        height: height,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return SizedBox(width: width, height: height, child: fallback);
        },
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return CachedNetworkImage(
      imageUrl: target,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, _) =>
          SizedBox(width: width, height: height, child: fallback),
      errorWidget: (context, _, _) => fallback,
    );
  }
}

/// Placeholder standar saat poster belum tersedia atau gagal dimuat.
class PosterPlaceholder extends StatelessWidget {
  final double? size;

  const PosterPlaceholder({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B3744), Color(0xFF1D252C)],
        ),
      ),
      child: Center(
        child: Icon(Icons.movie_rounded, color: Colors.white24, size: 32),
      ),
    );
  }
}
