import 'dart:typed_data';

import 'package:http/http.dart' as http;

class BackgroundRemovalService {
  const BackgroundRemovalService({this.httpClient});

  /// When null, a short-lived [http.Client] is created per request.
  final http.Client? httpClient;

  static const String _endpoint = 'https://api.remove.bg/v1.0/removebg';

  Future<Uint8List> removeBackground({
    required Uint8List imageBytes,
    required String fileName,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Missing remove.bg API key.');
    }

    final request = http.MultipartRequest('POST', Uri.parse(_endpoint))
      ..headers['X-Api-Key'] = apiKey
      ..fields['size'] = 'auto'
      ..files.add(
        http.MultipartFile.fromBytes(
          'image_file',
          imageBytes,
          filename: fileName,
        ),
      );

    final client = httpClient ?? http.Client();
    final closeClient = httpClient == null;
    try {
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        var message = response.body;
        if (message.length > 220) {
          message = '${message.substring(0, 220)}...';
        }
        throw Exception(
          'remove.bg request failed (${response.statusCode}): $message',
        );
      }

      return response.bodyBytes;
    } finally {
      if (closeClient) {
        client.close();
      }
    }
  }
}
