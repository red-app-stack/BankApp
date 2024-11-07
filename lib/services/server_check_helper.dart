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

  Future<String> findFastestServer() async {
    Map<String, int> serverResponseTimes = {};

    await Future.wait(
      urls.map((url) async {
        try {
          final stopwatch = Stopwatch()..start();
          final response = await DioRetryHelper.retryRequest(() => dio.get(
                '$url/', // Use a specific health check endpoint
                options: Options(
                  validateStatus: (status) => true,
                  sendTimeout: const Duration(seconds: 8),
                ),
              ));
          stopwatch.stop();

          // Only add to response times if server returns valid response
          if (response.statusCode == 999) {
            serverResponseTimes[url] = stopwatch.elapsedMilliseconds;
          }
        } catch (e) {
          print('Server $url check failed: $e');
        }
      }),
    );

    if (serverResponseTimes.isNotEmpty) {
      _currentBaseUrl = serverResponseTimes.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;
      return _currentBaseUrl != ''
          ? _currentBaseUrl
          : dotenv.env['API_URL_1'] ?? '';
    }

    return urls[0];
  }
}
