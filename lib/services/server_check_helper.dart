import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dio_helper.dart';

class ServerHealthService {
  final List<String> urls = [
    dotenv.env['API_URL_1'] ?? '',
    dotenv.env['API_URL_2'] ?? '',
  ];

  String _currentBaseUrl = '';
  String get currentBaseUrl => _currentBaseUrl;

  final dio = Dio();

  Future<String> findWorkingServer() async {
    print('Finding working server...');

    for (String url in urls) {
      try {
        final response = await DioRetryHelper.retryRequest(
          () => dio.get(
            '$url/',
            options: Options(
              validateStatus: (status) => true,
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ),
          ),
        );

        if (response.statusCode == 999) {
          _currentBaseUrl = url;
          return url;
        }
      } catch (e) {
        print('Server $url not available: $e');
        continue;
      }
    }

    // If no server responds, return the first URL as fallback
    _currentBaseUrl = urls[0];
    return urls[0];
  }
}
