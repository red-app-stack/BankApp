import 'package:bank_app/services/server_check_helper.dart';
import 'package:dio/dio.dart';

class DioManager {
  final ServerHealthService serverHealthService;
  late final Dio _dio;

  DioManager({required this.serverHealthService}) {
    _dio = Dio()
      ..options.baseUrl = serverHealthService.currentBaseUrl
      ..options.sendTimeout = const Duration(seconds: 20)
      ..options.receiveTimeout = const Duration(seconds: 20);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _makeRequest(
      () =>
          _dio.get<T>(path, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _makeRequest(
      () => _dio.post<T>(path,
          data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _makeRequest(
      () => _dio.delete<T>(path,
          data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> _makeRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    final String workingServerUrl =
        await serverHealthService.findWorkingServer();
    if (workingServerUrl != _dio.options.baseUrl) {
      _dio.options.baseUrl = workingServerUrl;
    }

    try {
      return await request();
    } on DioException catch (e) {
      print(e);
      return RetryHelper(this).retryRequest(() => request());
    }
  }
}

class RetryHelper {
  final DioManager _dioManager;
  static const int maxRetries = 5;

  RetryHelper(this._dioManager);

  Future<Response<T>> retryRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        attempts++;
        if (attempts == maxRetries) rethrow;

        if (e.response?.statusCode == 502 ||
            e.type == DioExceptionType.connectionTimeout) {
          final String newBaseUrl =
              await _dioManager.serverHealthService.findWorkingServer();
          if (newBaseUrl != _dioManager._dio.options.baseUrl) {
            print('Switching to new server: $newBaseUrl');
            _dioManager._dio.options.baseUrl = newBaseUrl;
          }
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
