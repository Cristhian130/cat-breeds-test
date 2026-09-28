import 'package:cat_breeds/core/design_system/atoms/adaptive_activity_indicator.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_radii.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Marco de imagen redondeado con una alternativa
/// consistente y una sombra suave.
class BrandPhoto extends StatefulWidget {
  const new({required this.imageUrl, required this.semanticLabel, super.key});

  final String? imageUrl;
  final String semanticLabel;

  @override
  State<BrandPhoto> createState() => _BrandPhotoState();
}

class _BrandPhotoState extends State<BrandPhoto> {
  final _timer = Stopwatch()..start();
  bool _reported = false;

  @override
  void didUpdateWidget(covariant BrandPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _timer
        ..reset()
        ..start();
      _reported = false;
    }
  }

  void _report(String status) {
    if (_reported) return;
    _reported = true;
    _timer.stop();
    if (kDebugMode) {
      debugPrint(
        'BreedImage name=${widget.semanticLabel} '
        'status=$status elapsedMs=${_timer.elapsedMilliseconds}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.imageUrl;
    if (url == null) _report('missing-url');

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BrandRadii.photo),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BrandRadii.photo),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Agrupa los anchos físicos para reutilizar ImageCache de Flutter.
            final width = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : 520.0;
            final pixels = width * MediaQuery.devicePixelRatioOf(context);
            final decodeWidth = ((pixels / 128).ceil() * 128).clamp(128, 1536);
            return url == null
                ? _placeholder(decodeWidth)
                : Image.network(
                    url,
                    cacheWidth: decodeWidth,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    semanticLabel: widget.semanticLabel,
                    frameBuilder: (context, child, frame, synchronous) {
                      if (frame != null) {
                        _report(synchronous ? 'cached' : 'loaded');
                        return child;
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          _placeholder(decodeWidth),
                          const Center(
                            child: SizedBox.square(
                              dimension: 24,
                              child: AdaptiveActivityIndicator(strokeWidth: 2),
                            ),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      _report('failed');
                      return _placeholder(decodeWidth);
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget _placeholder(int decodeWidth) => Image.asset(
    'assets/images/placeholders/placeholder.jpg',
    cacheWidth: decodeWidth,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    semanticLabel: widget.semanticLabel,
  );
}
