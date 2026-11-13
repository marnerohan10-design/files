import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../utils/constants.dart';

/// A readable error that the UI can show to the user as it is.
class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// All calls to the FakeStore API (https://fakestoreapi.com) live here.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<ProductModel>> getProducts() async {
    return _parseProducts(await _get('/products'));
  }

  Future<List<ProductModel>> getByCategory(String category) async {
    return _parseProducts(
      await _get('/products/category/${Uri.encodeComponent(category)}'),
    );
  }

  Future<ProductModel> getProduct(int id) async {
    final data = await _get('/products/$id');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('This product could not be found.');
    }
    try {
      return ProductModel.fromJson(data);
    } on FormatException {
      throw const ApiException('Received an invalid product from the server.');
    }
  }

  Future<List<String>> getCategories() async {
    final data = await _get('/products/categories');
    if (data is! List) {
      throw const ApiException('Received an invalid category list from the server.');
    }
    return data.map((e) => e.toString()).toList();
  }

  List<ProductModel> _parseProducts(dynamic data) {
    if (data is! List) {
      throw const ApiException('Received an invalid product list from the server.');
    }
    try {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } on FormatException {
      throw const ApiException('Received invalid product data from the server.');
    }
  }

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$path');
    try {
      final response = await _client.get(uri).timeout(AppConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'The server returned an error (${response.statusCode}). Please try again.',
        );
      }
      if (response.body.trim().isEmpty) {
        // FakeStore answers 200 with an empty body for unknown ids.
        throw const ApiException('No data was found for this request.');
      }
      return jsonDecode(response.body);
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const ApiException('Could not reach the server. Please try again.');
    } on FormatException {
      throw const ApiException('Received an invalid response from the server.');
    }
  }
}
