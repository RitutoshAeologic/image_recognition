import 'dart:io';
import 'package:image_recognition/core/service/tflite_service.dart';
import 'package:image_recognition/domain/model/prediction.dart';
import 'package:image_recognition/domain/repositories/image_recognition_repository.dart';

class ImageRecognitionRepositoryImpl
    implements ImageRecognitionRepository {

  final TFLiteService service;

  ImageRecognitionRepositoryImpl(this.service);

  @override
  Future<List<Prediction>> detect(File image) async {
    return service.runModelAsync(image);
  }
}