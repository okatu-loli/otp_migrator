import 'dart:typed_data';

Future<String?> saveTextFileImpl({
  required String suggestedName,
  required String content,
}) =>
    throw UnsupportedError('No platform implementation available');

Future<String?> saveQrImagesImpl(Map<String, Uint8List> namedPngs) =>
    throw UnsupportedError('No platform implementation available');
