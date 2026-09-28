import 'dart:async';
import 'dart:io';

import 'package:cat_breeds/core/design_system/atoms/brand_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets(
    'shows loading then reuses decoded image without downloading again',
    (tester) async {
      final client = _Client();
      final request = _Request();
      final response = Completer<HttpClientResponse>();
      final uri = Uri.parse('https://images.example.test/cat.jpg');
      when(() => client.getUrl(uri)).thenAnswer((_) async => request);
      when(request.close).thenAnswer((_) => response.future);
      debugNetworkImageHttpClientProvider = () => client;
      addTearDown(() {
        debugNetworkImageHttpClientProvider = null;
        PaintingBinding.instance.imageCache
          ..clear()
          ..clearLiveImages();
      });

      Widget photo() => MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 190,
            child: BrandPhoto(imageUrl: uri.toString(), semanticLabel: 'Cat'),
          ),
        ),
      );

      await tester.pumpWidget(photo());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image).first).image;
      final context = tester.element(find.byType(BrandPhoto));
      await tester.runAsync(() async {
        response.complete(
          _Response(
            File('assets/images/placeholders/placeholder.jpg')
                .readAsBytesSync(),
          ),
        );
        await precacheImage(image, context);
      });
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(photo());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      verify(() => client.getUrl(uri)).called(1);
      expect(tester.takeException(), isNull);
      debugNetworkImageHttpClientProvider = null;
    },
  );
}

class _Client extends Mock implements HttpClient;

class _Request extends Mock implements HttpClientRequest;

class _Response extends StreamView<List<int>> implements HttpClientResponse {
  new(this.bytes) : super(Stream.value(bytes));

  final List<int> bytes;

  @override
  int get statusCode => 200;

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
