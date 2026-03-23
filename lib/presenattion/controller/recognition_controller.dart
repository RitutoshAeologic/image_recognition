
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_recognition/core/service/tflite_service.dart';
import 'package:image_recognition/domain/model/prediction.dart';
import 'package:image_recognition/domain/usecases/detect_objects_usecase.dart';


enum RecognitionState { idle, picking, inferring, done, error }

class RecognitionController extends GetxController {
  final DetectObjectsUseCase detectObjects;
  RecognitionController(this.detectObjects);

  // ── Observables ──────────────────────────────
  final state        = RecognitionState.idle.obs;
  final image        = Rx<File?>(null);
  final predictions  = <Prediction>[].obs;
  final errorMessage = ''.obs;

  final picker = ImagePicker();
  bool _modelLoaded = false;
  bool get modelLoaded => _modelLoaded;

  @override
  void onInit() {
    super.onInit();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      state.value = RecognitionState.inferring;
      await Get.find<TFLiteService>().loadModel();
      _modelLoaded = true;
    } catch (e) {
      _setError('Model failed to load: $e');
    } finally {
      if (state.value == RecognitionState.inferring) {
        state.value = RecognitionState.idle;
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    if (!_modelLoaded) {
      Get.snackbar('Not ready', 'Model is still loading, please wait…',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      // Clear immediately so UI doesn't show stale results.
      predictions.clear();
      image.value = null;
      state.value = RecognitionState.picking;

      final picked = await picker.pickImage(source: source, imageQuality: 85);

      if (picked == null) {
        state.value = RecognitionState.idle;
        return;
      }

      // Set image BEFORE changing state so _InferringCard can render it.
      image.value = File(picked.path);

      // One-frame yield — Flutter renders the image + spinner overlay
      // before the background isolate is spawned.
      await Future<void>.delayed(const Duration(milliseconds: 32));

      await _runInference();
    } catch (e) {
      _setError('Image error: $e');
    }
  }

  Future<void> retryInference() async {
    if (image.value == null) return;
    await _runInference();
  }

  Future<void> _runInference() async {
    if (image.value == null) return;
    try {
      state.value = RecognitionState.inferring;

      // runModelAsync() runs everything in a background isolate via compute().
      // Main thread stays free → spinner animates the whole time.
      final result =
      await Get.find<TFLiteService>().runModelAsync(image.value!);

      predictions.assignAll(result);
      state.value = RecognitionState.done;
    } catch (e) {
      _setError('Inference failed: $e');
    }
  }

  void _setError(String msg) {
    errorMessage.value = msg;
    state.value = RecognitionState.error;
    Get.snackbar('Error', msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4));
  }

  bool get isIdle      => state.value == RecognitionState.idle;
  bool get isPicking   => state.value == RecognitionState.picking;
  bool get isInferring => state.value == RecognitionState.inferring;
  bool get isDone      => state.value == RecognitionState.done;
  bool get hasImage    => image.value != null;
  bool get isBusy      => isPicking || isInferring;
}
