import 'package:dio/dio.dart';
import 'package:facetest/face_pose.dart';
abstract class FaceVerificationRepository {
  Future<void> submitVerification({
    required String userId,
    required List<CapturedFaceImage> images,
  });
}

class DioFaceVerificationRepository implements FaceVerificationRepository {
  final Dio _dio;
  final String uploadPath;

  DioFaceVerificationRepository(
    this._dio, {
    this.uploadPath = '/face-verification',
  });

  @override
  Future<void> submitVerification({
    required String userId,
    required List<CapturedFaceImage> images,
  }) async {
    final formData = FormData.fromMap({
      'userId': userId,
      for (final img in images)
        img.pose.name: await MultipartFile.fromFile(
          img.file.path,
          filename: '${img.pose.name}.jpg',
        ),
    });

    final response = await _dio.post(uploadPath, data: formData);

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        'Face verification upload failed: ${response.statusCode}',
      );
    }
  }
}
