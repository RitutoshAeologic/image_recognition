import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:image_recognition/presenattion/controller/recognition_controller.dart';
import 'package:image_recognition/presenattion/screens/recognition_screen.dart';
import 'package:get/get.dart';

import 'core/service/tflite_service.dart';
import 'data/repositories/image_recognition_repository_impl.dart';
import 'domain/usecases/detect_objects_usecase.dart';

void main() async {
  initDependencies();
  runApp(const MyApp());
  await Get.find<TFLiteService>().loadModel();

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Offline Image Recognition",

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: RecognitionScreen(),
    );
  }
}

void initDependencies() {

  final service = TFLiteService();

  final repository =
  ImageRecognitionRepositoryImpl(service);

  final useCase =
  DetectObjectsUseCase(repository);

  Get.put(service, permanent: true);

  Get.put(
    RecognitionController(useCase),
    permanent: true,
  );
}