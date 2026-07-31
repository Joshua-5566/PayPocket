import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../repository/transaction_repository.dart';

class TransactionNotifier extends StateNotifier<List<ExpenseTransaction>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final list = await _repository.getAll();
    state = list;
  }

  // Load from repository
  Future<void> load() async {
    final list = await _repository.getAll();
    state = list;
  }

  // Add new transaction
  Future<void> add(ExpenseTransaction tx) async {
    await _repository.save(tx);
    state = [...state, tx];
  }

  // Delete by id
  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = state.where((tx) => tx.id != id).toList();
  }

  // Update existing
  Future<void> update(ExpenseTransaction tx) async {
    await _repository.update(tx);
    final index = state.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      state = [
        ...state.sublist(0, index),
        tx,
        ...state.sublist(index + 1),
      ];
    }
  }
}
