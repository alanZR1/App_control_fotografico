import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../domain/watermark_service.dart';

class ImageWatermarkService implements WatermarkService {
  @override
  Future<String> createWatermarkedCopy({
    required String sourcePath,
    required WatermarkData data,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final evidenceDirectory = Directory('${directory.path}/evidencias');
    await evidenceDirectory.create(recursive: true);
    final outputPath =
        '${evidenceDirectory.path}/evidencia_${DateTime.now().microsecondsSinceEpoch}.jpg';

    return Isolate.run(
      () => _renderWatermark(
        sourcePath: sourcePath,
        outputPath: outputPath,
        data: data,
      ),
    );
  }
}

String _renderWatermark({
  required String sourcePath,
  required String outputPath,
  required WatermarkData data,
}) {
  final bytes = File(sourcePath).readAsBytesSync();
  final source = img.decodeImage(bytes);
  if (source == null) throw const FormatException('La imagen no es válida.');

  final oriented = img.bakeOrientation(source);
  final scale = (oriented.width / 1080).clamp(0.75, 2.5);
  final padding = (24 * scale).round();
  final lineHeight = (34 * scale).round();
  final panelHeight = padding * 2 + lineHeight * 3;
  final panelTop = oriented.height - panelHeight;

  img.fillRect(
    oriented,
    x1: 0,
    y1: panelTop,
    x2: oriented.width,
    y2: oriented.height,
    color: img.ColorRgba8(0, 0, 0, 178),
  );

  final date = _formatDate(data.capturedAt);
  final time = _formatTime(data.capturedAt);
  final lines = [
    'OBRA: ${data.workFolio}',
    '$date  $time',
    'GPS: ${data.latitude.toStringAsFixed(6)}, ${data.longitude.toStringAsFixed(6)}',
  ];
  final font = scale >= 1.35 ? img.arial48 : img.arial24;
  for (var index = 0; index < lines.length; index++) {
    img.drawString(
      oriented,
      lines[index],
      font: font,
      x: padding,
      y: panelTop + padding + index * lineHeight,
      color: img.ColorRgb8(255, 255, 255),
    );
  }

  File(outputPath).writeAsBytesSync(img.encodeJpg(oriented, quality: 90));
  return outputPath;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
String _formatDate(DateTime date) =>
    '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
String _formatTime(DateTime date) =>
    '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
