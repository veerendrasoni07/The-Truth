import 'package:flutter/foundation.dart';

import '../models/project_ledger.dart';
import '../services/ledger_repository.dart';

enum LedgerLoadState { initial, loading, success, error }

class LedgerProvider extends ChangeNotifier {
  LedgerProvider({LedgerRepository? repository})
      : _repository = repository ?? LedgerRepository();

  final LedgerRepository _repository;

  LedgerLoadState _state = LedgerLoadState.initial;
  List<ProjectLedger> _projects = [];
  String? _errorMessage;
  DateTime? _lastSyncedAt;

  LedgerLoadState get state => _state;
  List<ProjectLedger> get projects => List.unmodifiable(_projects);
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  Future<void> loadLedger({bool forceRefresh = false}) async {
    if (_state == LedgerLoadState.loading) return;

    _state = LedgerLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.fetchLedger();
      _projects = data;
      _lastSyncedAt = DateTime.now();
      _state = LedgerLoadState.success;
    } on LedgerFetchException catch (e) {
      _errorMessage = e.message;
      _state = _projects.isEmpty ? LedgerLoadState.error : LedgerLoadState.success;
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _state = _projects.isEmpty ? LedgerLoadState.error : LedgerLoadState.success;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
