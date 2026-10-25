import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/failures.dart';
import '../models/scanned_food_product.dart';
import '../utils/result.dart';
import 'nutrition_service.dart';

/// Concrete implementation of [NutritionService] querying the Open Food Facts API v2.
///
/// Documentation: https://openfoodfacts.github.io/documentation/
class OpenFoodFactsNutritionService implements NutritionService {
  final http.Client _client;
  final Duration _timeout;

  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v2/product';
  static const String _requestedFields =
      'code,product_name,brands,image_url,serving_size,nutriments';
  static const String _userAgent =
      'NuroVed-PatientApp/1.0.0 (https://nuroved.com; contact@nuroved.com)';

  OpenFoodFactsNutritionService({
    http.Client? client,
    Duration timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       _timeout = timeout;

  @override
  Future<Result<ScannedFoodProduct>> lookupBarcode(String barcode) async {
    final sanitizedBarcode = barcode.trim();
    if (sanitizedBarcode.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Barcode cannot be empty.'),
      );
    }

    final uri = Uri.parse(
      '$_baseUrl/$sanitizedBarcode.json?fields=$_requestedFields',
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;

        final status = body['status'];
        if (status == 1 || status == '1') {
          final product = ScannedFoodProduct.fromOpenFoodFactsJson(
            sanitizedBarcode,
            body,
          );
          return Result.success(product);
        } else {
          final statusVerbose = body['status_verbose'] ?? 'Product not found';
          return Result.failure(
            NotFoundFailure(
              message:
                  'Product not found in Open Food Facts database ($statusVerbose).',
            ),
          );
        }
      } else if (response.statusCode == 404) {
        return Result.failure(
          NotFoundFailure(
            message:
                'Product with barcode "$sanitizedBarcode" was not found in the nutrition database.',
          ),
        );
      } else if (response.statusCode == 429) {
        return const Result.failure(
          ServerFailure(
            message:
                'Open Food Facts rate limit reached. Please wait a moment and try again.',
            code: 'RATE_LIMIT',
          ),
        );
      } else if (response.statusCode >= 500) {
        return const Result.failure(
          ServerFailure(
            message:
                'Open Food Facts servers are currently experiencing issues. Please try again later.',
          ),
        );
      } else {
        return Result.failure(
          ServerFailure(
            message:
                'Unable to retrieve nutrition facts (HTTP ${response.statusCode}).',
          ),
        );
      }
    } on TimeoutException {
      return const Result.failure(
        NetworkFailure(
          message:
              'Nutrition database lookup timed out. Please check your network connection and retry.',
        ),
      );
    } on SocketException catch (e) {
      return Result.failure(
        NetworkFailure(
          message:
              'Unable to reach Open Food Facts. Please verify your internet connection.',
          cause: e,
        ),
      );
    } on FormatException catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'Received an invalid response from Open Food Facts.',
          cause: e,
        ),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(
          message: 'An error occurred during barcode lookup: $e',
          cause: e,
        ),
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
