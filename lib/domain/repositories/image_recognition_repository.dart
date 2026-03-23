import 'dart:io';

import 'package:image_recognition/domain/model/prediction.dart';

abstract class ImageRecognitionRepository {
  Future<List<Prediction>> detect(File image);
}