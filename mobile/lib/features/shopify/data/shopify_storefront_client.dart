import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShopifyClientException implements Exception {
  final String message;
  final int? statusCode;
  final List<dynamic>? errors;

  ShopifyClientException(this.message, {this.statusCode, this.errors});

  @override
  String toString() =>
      'ShopifyClientException: $message (statusCode: $statusCode, errors: $errors)';
}

class ShopifyStorefrontClient {
  final String domain;
  final String apiVersion;
  final String storefrontAccessToken;
  final http.Client _httpClient;

  ShopifyStorefrontClient({
    String? domain,
    String? apiVersion,
    String? storefrontAccessToken,
    http.Client? httpClient,
  }) : domain =
           domain ??
           (dotenv.isInitialized ? dotenv.env['SHOPIFY_STORE_DOMAIN'] : null) ??
           'muu1gj-t6.myshopify.com',
       apiVersion =
           apiVersion ??
           (dotenv.isInitialized
               ? dotenv.env['SHOPIFY_STOREFRONT_API_VERSION']
               : null) ??
           '2026-04',
       storefrontAccessToken =
           storefrontAccessToken ??
           (dotenv.isInitialized
               ? dotenv.env['SHOPIFY_STOREFRONT_PUBLIC_TOKEN']
               : null) ??
           'c16886e0fae04d0cd9d3252994d79f5b',
       _httpClient = httpClient ?? http.Client();

  Uri get _endpointUri =>
      Uri.parse('https://$domain/api/$apiVersion/graphql.json');

  Future<Map<String, dynamic>> query({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Shopify-Storefront-Access-Token': storefrontAccessToken,
    };

    final body = jsonEncode({
      'query': query,
      if (variables != null) ...{'variables': variables},
    });

    try {
      final response = await _httpClient.post(
        _endpointUri,
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw ShopifyClientException(
          'HTTP request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json.containsKey('errors') && json['errors'] != null) {
        final errors = json['errors'] as List<dynamic>;
        if (errors.isNotEmpty) {
          throw ShopifyClientException(
            errors.first['message'] ?? 'GraphQL Query Error',
            errors: errors,
          );
        }
      }

      final data = json['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw ShopifyClientException('Response data is null or invalid');
      }

      return data;
    } catch (e) {
      if (e is ShopifyClientException) rethrow;
      throw ShopifyClientException('Network error connecting to Shopify: $e');
    }
  }
}
