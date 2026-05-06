/// Lightweight internet reachability checks for app-wide connectivity.
library;

import 'dart:async';
import 'dart:io';

import 'package:apex_chess/core/network/connectivity_models.dart';

class ConnectivityService {
  ConnectivityService({
    this.timeout = const Duration(milliseconds: 1200),
    List<Uri>? endpoints,
  }) : endpoints =
           endpoints ??
           const [
             'https://www.gstatic.com/generate_204',
             'https://cloudflare.com/cdn-cgi/trace',
           ].map(Uri.parse).toList(growable: false);

  final Duration timeout;
  final List<Uri> endpoints;

  Future<NetworkAvailability> checkInternet() async {
    var sawCaptive = false;
    var sawUnstable = false;
    for (final endpoint in endpoints) {
      final result = await _probe(endpoint);
      if (result == NetworkAvailability.online) {
        return NetworkAvailability.online;
      }
      sawCaptive = sawCaptive || result == NetworkAvailability.captiveOrBlocked;
      sawUnstable = sawUnstable || result == NetworkAvailability.unstable;
    }
    if (sawCaptive) return NetworkAvailability.captiveOrBlocked;
    if (sawUnstable) return NetworkAvailability.unstable;
    return NetworkAvailability.offline;
  }

  Future<NetworkAvailability> _probe(Uri endpoint) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(endpoint).timeout(timeout);
      request.followRedirects = false;
      final response = await request.close().timeout(timeout);
      final statusCode = response.statusCode;
      await response.drain<void>();

      if (statusCode == HttpStatus.noContent ||
          (statusCode >= 200 && statusCode < 300)) {
        return NetworkAvailability.online;
      }
      if (statusCode >= 300 && statusCode < 400) {
        return NetworkAvailability.captiveOrBlocked;
      }
      if (statusCode == HttpStatus.unauthorized ||
          statusCode == HttpStatus.forbidden) {
        return NetworkAvailability.captiveOrBlocked;
      }
      return NetworkAvailability.unstable;
    } on TimeoutException {
      return NetworkAvailability.unstable;
    } on SocketException {
      return NetworkAvailability.offline;
    } catch (_) {
      return NetworkAvailability.unstable;
    } finally {
      client.close(force: true);
    }
  }
}
