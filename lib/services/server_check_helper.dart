import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerHealthService {
  final List<String> urls = [
    dotenv.env['API_URL_1'] ?? '',
    dotenv.env['API_URL_2'] ?? '',
    dotenv.env['API_URL_3'] ?? '',
    dotenv.env['API_URL_4'] ?? '',
  ];

  String _currentBaseUrl = '';
  String get currentBaseUrl => _currentBaseUrl;

  final dio = Dio();
  final _serverHealthCache = <String, ServerHealth>{};
  final _serverHealthExpiration = const Duration(minutes: 5);

  Future<String> findWorkingServer() async {
    print('Finding working server...');

    // Check cached server health first
    final cachedServer = _getCachedServerHealth();
    if (cachedServer != null) {
      return cachedServer.url;
    }

    // Asynchronously check the health of all servers
    final serverHealthFutures = urls.map((url) => _checkServerHealth(url));
    final serverHealthResults = await Future.wait(serverHealthFutures);

    // Find the best available server
    final bestServer = _findBestServer(serverHealthResults);
    if (bestServer != null) {
      _currentBaseUrl = bestServer.url;
      _cacheServerHealth(bestServer);
      return bestServer.url;
    }

    // If no server is available, use the first URL as a fallback
    _currentBaseUrl = urls[0];
    return urls[0];
  }

  Future<ServerHealth> _checkServerHealth(String url) async {
    if (url.isEmpty) {
      return ServerHealth(url: url, statusCode: 0, responseTime: null);
    }
    try {
      final response = await dio.get(
        '$url/',
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final health = ServerHealth(
        url: url,
        statusCode: response.statusCode ?? 0,
        responseTime: response.requestOptions.extra['duration'] as int?,
      );
      return health;
    } catch (e) {
      return ServerHealth(url: url, statusCode: 0, responseTime: null);
    }
  }

  ServerHealth? _getCachedServerHealth() {
    final now = DateTime.now();
    return _serverHealthCache.values.firstWhereOrNull((health) =>
        now.difference(health.cachedAt) < _serverHealthExpiration);
  }

  void _cacheServerHealth(ServerHealth health) {
    _serverHealthCache[health.url] = health..cachedAt = DateTime.now();
  }

  ServerHealth? _findBestServer(List<ServerHealth> serverHealthResults) {
    serverHealthResults.sort((a, b) {
      // Sort by status code (higher is better) and response time (lower is better)
      final statusDiff = b.statusCode.compareTo(a.statusCode);
      if (statusDiff != 0) return statusDiff;
      return a.responseTime?.compareTo(b.responseTime ?? 0) ?? 0;
    });
    return serverHealthResults.isNotEmpty ? serverHealthResults.first : null;
  }
}

class ServerHealth {
  final String url;
  final int statusCode;
  final int? responseTime;
  DateTime cachedAt = DateTime.now();

  ServerHealth({
    required this.url,
    required this.statusCode,
    required this.responseTime,
  });
}