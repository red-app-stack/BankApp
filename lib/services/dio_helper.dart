import 'package:bank_app/services/server_check_helper.dart';
import 'package:dio/dio.dart';
import 'package:get/instance_manager.dart';

class DioRetryHelper {
  static const int maxRetries = 5;
  static final ServerHealthService serverHealthService = Get.find();

  static Future<Response<T>> retryRequest<T>(
      Future<Response<T>> Function() request) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        print('DioException details:');
        print('Server: ${e.response?.realUri}');
        print('Status code: ${e.response?.statusCode}');
        if (e.response?.statusCode == null) {}
        print('Response data: ${e.response?.data}');
        print('Request path: ${e.requestOptions.path}');
        print('Request data: ${e.requestOptions.data}');

        attempts++;
        if (attempts == maxRetries) rethrow;
        if (e.response?.statusCode == 502 ||
            e.type == DioExceptionType.connectionTimeout) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        } else if (e.response?.statusCode == null) {
          await Future.delayed(const Duration(seconds: 1));
        }
        rethrow;
      }
    }
    throw DioException(requestOptions: RequestOptions(path: ''));
  }
}
