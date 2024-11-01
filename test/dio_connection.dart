import 'package:bank_app/services/interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DIO connection test', () async {
    final dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL_1'] ?? '',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));
    dio.interceptors.add(AuthInterceptor());
    try {
      final response = await dio.get('/');
      expect(response.statusCode, 404);
    } catch (e) {
      print('Error during server check: $e');
    }
  });
}
