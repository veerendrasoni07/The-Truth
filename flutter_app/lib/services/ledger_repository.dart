import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/project_ledger.dart';

class LedgerFetchException implements Exception {
  LedgerFetchException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class LedgerRepository {
  LedgerRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<ProjectLedger>> fetchLedger({String? urlOverride}) async {
    final url = urlOverride ?? AppConfig.ledgerUrl;
    final response = await _client
        .get(Uri.parse(url))
        .timeout(AppConfig.httpTimeout);

    if (response.statusCode != 200) {
      throw LedgerFetchException(
        'Ledger fetch failed (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw LedgerFetchException('Invalid ledger format: expected JSON object');
    }

    final projects = decoded.entries
        .map((entry) {
          final value = entry.value;
          if (value is! Map<String, dynamic>) return null;
          return ProjectLedger.fromJson(value);
        })
        .whereType<ProjectLedger>()
        .toList();

    projects.sort((a, b) => a.title.compareTo(b.title));
    return projects;
  }

  void dispose() => _client.close();
}
