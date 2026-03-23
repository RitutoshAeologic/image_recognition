import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../domain/model/prediction.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
//  Data passed into the background isolate.
//  Everything must be sendable across isolate boundaries
//  (no Interpreter, no rootBundle — only plain Dart types).
// ─────────────────────────────────────────────
class _InferencePayload {
  final String imagePath;
  final List<String> labels;
  final Uint8List modelBytes; // raw .tflite bytes, loaded on main thread

  const _InferencePayload({
    required this.imagePath,
    required this.labels,
    required this.modelBytes,
  });
}

// ─────────────────────────────────────────────
//  Top-level function run by compute().
//  Must be top-level (not a closure / instance method).
// ─────────────────────────────────────────────
List<Map<String, dynamic>> _runInferenceInBackground(_InferencePayload payload) {
  // Build a fresh interpreter from the raw bytes inside the isolate.
  final interpreter = Interpreter.fromBuffer(
    payload.modelBytes,
    options: InterpreterOptions()..threads = 4,
  );

  final image = img.decodeImage(File(payload.imagePath).readAsBytesSync());
  if (image == null) throw Exception('Cannot decode image');

  final resized = img.copyResize(image, width: 224, height: 224);

  final input = Uint8List(1 * 224 * 224 * 3);
  int idx = 0;
  for (int y = 0; y < 224; y++) {
    for (int x = 0; x < 224; x++) {
      final pixel = resized.getPixel(x, y);
      input[idx++] = pixel.r.toInt();
      input[idx++] = pixel.g.toInt();
      input[idx++] = pixel.b.toInt();
    }
  }

  final output = List.generate(1, (_) => List.filled(payload.labels.length, 0));
  interpreter.run(input.buffer, output);
  interpreter.close();

  final results = <Map<String, dynamic>>[];
  for (int i = 0; i < payload.labels.length; i++) {
    final confidence = output[0][i] / 255.0;
    if (confidence > 0.15) {
      results.add({'label': payload.labels[i], 'confidence': confidence});
    }
  }
  results.sort((a, b) =>
      (b['confidence'] as double).compareTo(a['confidence'] as double));

  return results.take(3).toList();
}

// ─────────────────────────────────────────────
//  TFLiteService
// ─────────────────────────────────────────────
class TFLiteService {
  List<String> _labels = [];
  Uint8List? _modelBytes; // kept in memory so compute() can send it
  bool _isLoaded = false;

  Future<void> loadModel() async {
    try {
      // Load model bytes via rootBundle on the main thread.
      final modelData = await rootBundle.load('assets/model/mobilenet_v2.tflite');
      _modelBytes = modelData.buffer.asUint8List();

      // Quick sanity-check: build + immediately close an interpreter.
      final testInterp = Interpreter.fromBuffer(
        _modelBytes!,
        options: InterpreterOptions()..threads = 1,
      );
      debugPrint('Input  shape: ${testInterp.getInputTensor(0).shape}');
      debugPrint('Output shape: ${testInterp.getOutputTensor(0).shape}');
      testInterp.close();

      final raw = await rootBundle.loadString('assets/labels/labels.txt');
      _labels = raw.split('\n').where((e) => e.trim().isNotEmpty).toList();
      debugPrint('Labels loaded: ${_labels.length}');

      _isLoaded = true;
    } catch (e) {
      throw Exception('Model loading failed: $e');
    }
  }

  /// Runs inference on a background isolate so the UI thread stays free.
  Future<List<Prediction>> runModelAsync(File imageFile) async {
    if (!_isLoaded || _modelBytes == null) {
      throw Exception('Model not loaded');
    }

    final payload = _InferencePayload(
      imagePath: imageFile.path,
      labels: _labels,
      modelBytes: _modelBytes!,
    );

    // compute() serialises payload, spawns an isolate, deserialises result.
    // The main thread is free to render frames during this entire call.
    final raw = await compute(_runInferenceInBackground, payload);

    return raw
        .map((m) => Prediction(
      label: m['label'] as String,
      confidence: m['confidence'] as double,
    ))
        .toList();
  }
}