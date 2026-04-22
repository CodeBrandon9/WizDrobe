import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wizdrobe/background_removal_service.dart';

void main() {
  group('BackgroundRemovalService', () {
    test('throws when API key is empty', () async {
      const service = BackgroundRemovalService();
      await expectLater(
        service.removeBackground(
          imageBytes: Uint8List.fromList([1]),
          fileName: 'a.png',
          apiKey: '',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Missing remove.bg API key'),
          ),
        ),
      );
    });

    test('throws when API key is whitespace only', () async {
      const service = BackgroundRemovalService();
      await expectLater(
        service.removeBackground(
          imageBytes: Uint8List.fromList([1]),
          fileName: 'a.png',
          apiKey: '   \t  ',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('returns response bytes on HTTP 200', () async {
      final expected = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), contains('remove.bg'));
        expect(request.headers['X-Api-Key'], 'test-key');
        return http.Response.bytes(expected, 200);
      });

      final service = BackgroundRemovalService(httpClient: client);
      final out = await service.removeBackground(
        imageBytes: Uint8List.fromList([255]),
        fileName: 'shirt.png',
        apiKey: 'test-key',
      );

      expect(out, expected);
    });

    test('throws on non-200 status', () async {
      final client = MockClient(
        (_) async => http.Response('{"error":"bad"}', 402),
      );

      final service = BackgroundRemovalService(httpClient: client);
      await expectLater(
        service.removeBackground(
          imageBytes: Uint8List(1),
          fileName: 'x.png',
          apiKey: 'k',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            allOf([
              contains('remove.bg request failed (402)'),
              contains('{"error":"bad"}'),
            ]),
          ),
        ),
      );
    });
  });
}
