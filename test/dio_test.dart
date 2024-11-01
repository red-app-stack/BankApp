import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  test('DIO connection test', () async {
    print('Api in test: ${dotenv.env['API_URL_1'] ?? ''}');

    final dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL_1'] ?? '',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));
    try {
      final response = await dio.get('/');
      expect(response.statusCode, 404);
    } catch (e) {
      print('Error during server check: $e');
    }
  });
}
