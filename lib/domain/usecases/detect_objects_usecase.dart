
import 'dart:io';
import 'package:image_recognition/domain/model/prediction.dart';
import 'package:image_recognition/domain/repositories/image_recognition_repository.dart';

class DetectObjectsUseCase {

  final ImageRecognitionRepository repository;

  DetectObjectsUseCase(this.repository);

  Future<List<Prediction>> call(File image) {
    return repository.detect(image);
  }
}