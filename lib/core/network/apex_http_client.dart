/// Small JSON-oriented HTTP abstraction for feature infrastructure code.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

abstract class ApexHttpClient {
  const ApexHttpClient();

  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  });
}

class ApexHttpResponse {
  const ApexHttpResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  bool get isSuccessStatusCode => statusCode >= 200 && statusCode < 300;
}

class ApexHttpNetworkException implements Exception {
  const ApexHttpNetworkException([this.message = 'Network request failed']);

  final String message;

  @override
  String toString() => message;
}

class PackageApexHttpClient extends ApexHttpClient {
  PackageApexHttpClient({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final pending = _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      final response = timeout == null
          ? await pending
          : await pending.timeout(timeout);
      return ApexHttpResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
      );
    } on http.ClientException catch (error) {
      throw ApexHttpNetworkException(error.message);
    } on SocketException catch (error) {
      throw ApexHttpNetworkException(error.message);
    }
  }

  void close() => _client.close();
}
