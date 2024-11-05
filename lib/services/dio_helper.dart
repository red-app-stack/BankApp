import 'package:dio/dio.dart';

class DioRetryHelper {
  static const int maxRetries = 5;

  static Future<Response<T>> retryRequest<T>(
      Future<Response<T>> Function() request) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        print('DioException details:');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        print('Request path: ${e.requestOptions.path}');
        print('Request data: ${e.requestOptions.data}');

        attempts++;
        if (attempts == maxRetries) rethrow;
        if (e.response?.statusCode == 502 ||
            e.type == DioExceptionType.connectionTimeout) {
          await Future.delayed(Duration(seconds: 1));
          continue;
        }
        rethrow;
      }
    }
    throw DioException(requestOptions: RequestOptions(path: ''));
  }
}
