import 'dart:async';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerHealthService {
  final int workingCode = 999;
  final List<String> urls = [
    dotenv.env['API_URL_1'] ?? '',
    dotenv.env['API_URL_2'] ?? '',
    dotenv.env['API_URL_3'] ?? '',
    dotenv.env['API_URL_4'] ?? '',
  ].where((url) => url.isNotEmpty).toList();

  final _stopwatch = Stopwatch();

  String _currentBaseUrl = '';
  String get currentBaseUrl => _currentBaseUrl;

  final dio = Dio();
  final _serverHealthCache = <String, ServerHealth>{};
  final _serverHealthExpiration = const Duration(minutes: 5);

  Future<String> findWorkingServer() async {
    final cachedServer = _getCachedServerHealth();
    if (cachedServer != null && _isHealthy(cachedServer)) {
      print('Using cached server: ${cachedServer.url}');
      _currentBaseUrl = cachedServer.url;
      return cachedServer.url;
    }

    print('Checking all servers...');
    final serverHealthResults = await _checkAllServers();

    final bestServer = _findBestServer(serverHealthResults);
    if (bestServer != null) {
      _currentBaseUrl = bestServer.url;
      _cacheServerHealth(bestServer);
      print(
          'Selected best server: ${bestServer.url} (Status: ${bestServer.statusCode}, Response Time: ${bestServer.responseTime}ms)');
      return bestServer.url;
    }

    throw Exception('No working servers found');
  }

  Future<List<ServerHealth>> _checkAllServers() async {
    final results = <ServerHealth>[];

    // Check servers sequentially to avoid overwhelming the network
    for (final url in urls) {
      try {
        final health = await _checkServerHealth(url);
        results.add(health);

        // If we find a server with excellent health, use it immediately
        if (_isExcellentHealth(health)) {
          print('Found excellent server: $url');
          break;
        }
      } catch (e) {
        print('Error checking server $url: $e');
      }
    }

    return results;
  }

  Future<ServerHealth> _checkServerHealth(String url) async {
    _stopwatch.reset();
    _stopwatch.start();

    try {
      final response = await dio.get(
        '$url/server-check',
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      _stopwatch.stop();
      final responseTime = _stopwatch.elapsedMilliseconds;

      return ServerHealth(
        url: url,
        statusCode: response.statusCode ?? 0,
        responseTime: responseTime,
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      _stopwatch.stop();
      return ServerHealth(
        url: url,
        statusCode: 0,
        responseTime: null,
        lastChecked: DateTime.now(),
      );
    }
  }

  bool _isHealthy(ServerHealth health) {
    return health.statusCode == workingCode &&
        health.responseTime != null &&
        health.responseTime! < 1000 && // Less than 1 second
        DateTime.now().difference(health.lastChecked) < _serverHealthExpiration;
  }

  bool _isExcellentHealth(ServerHealth health) {
    return health.statusCode == workingCode &&
        health.responseTime != null &&
        health.responseTime! < 300;
  }

  ServerHealth? _getCachedServerHealth() {
    final now = DateTime.now();
    return _serverHealthCache.values.firstWhereOrNull((health) =>
        now.difference(health.lastChecked) < _serverHealthExpiration);
  }

  void _cacheServerHealth(ServerHealth health) {
    _serverHealthCache[health.url] = health;
  }

  ServerHealth? _findBestServer(List<ServerHealth> servers) {
    if (servers.isEmpty) return null;

    final healthyServers = servers
        .where((server) =>
            server.statusCode == workingCode && server.responseTime != null)
        .toList();

    if (healthyServers.isEmpty) return null;

    healthyServers.sort((a, b) {
      final aTime = a.responseTime ?? double.infinity;
      final bTime = b.responseTime ?? double.infinity;
      return aTime.compareTo(bTime);
    });

    return healthyServers.first;
  }
}

class ServerHealth {
  final String url;
  final int statusCode;
  final int? responseTime;
  final DateTime lastChecked;

  ServerHealth({
    required this.url,
    required this.statusCode,
    required this.responseTime,
    required this.lastChecked,
  });

  @override
  String toString() =>
      'ServerHealth(url: $url, status: $statusCode, response: ${responseTime}ms)';
}
