import 'package:csp10_app/core/services/api/api.dart';
import 'package:csp10_app/core/services/api/models/responses.dart';
import 'package:csp10_app/features/bear/models/beartransaction.dart';
import 'package:csp10_app/features/bear/models/beartype.dart';
import 'package:csp10_app/features/bear/models/brownbear.dart';

class BearRepository {
  final API _apiClient;
  List<BearType>? _beartypes;
  // List<BearTransaction>? _transactions;
  // List<BearTransaction>? _ownTransactions;

  BearRepository({API? apiClient}) : _apiClient = apiClient ?? API();

  Future<List<BearType>> get beartypes async {
    return _beartypes ??= await _getBearTypes();
  }

  // Future<List<BearTransaction>> get transactions async {
  //   return _transactions ??= await _getAllTransactions();
  // }

  // Future<List<BearTransaction>> get ownTransactions async {
  //   return _ownTransactions ??= await _getOwnTransactions();
  // }

  // Future<List<BearTransaction>> refreshTransactions() async {
  //   return _transactions = await _getAllTransactions();
  // }

  // Future<List<BearTransaction>> refreshOwnTransactions() async {
  //   return _ownTransactions = await _getOwnTransactions();
  // }

  Future<int> getBearCountByType(int bearTypeId) async {
    var response = await _getBearsByType(bearTypeId);
    return response.length;
  }

  Future<List<BrownBear>> getBrownBears() async {
    var response = await _getBearsByType(1);
    List<BrownBear> result = [];
    for (var element in response) {
      element = element as Map<String, dynamic>;
      result.add(BrownBear.fromJson(element));
    }
    return result;
  }

  Future<BearTransaction> useBrownBear(Map<String, Object> payload) async {
    var response = await _apiClient.postProtected('/bear/use', payload);
    switch (response) {
      case ContentAPIResponse _:
        var result =
            BearTransaction.fromJson(response.data as Map<String, dynamic>);
        return result;
      default:
        throw ErrorAPIResponse('Error in useBrownBear()');
    }
  }

  Future<List<BearTransaction>> getAllTransactions() async {
    var response = await _apiClient.getProtected('/transactions');
    switch (response) {
      case ContentListAPIResponse _:
        List<BearTransaction> result = [];
        for (var element in response.data) {
          element = element as Map<String, dynamic>;
          result.add(BearTransaction.fromJson(element));
        }
        // sort from newest to oldest
        result.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
        return result;
      default:
        throw ErrorAPIResponse('Error in _getBearTransactions()');
    }
  }

  Future<List<BearTransaction>> getOwnTransactions() async {
    var response = await _apiClient.getProtected('/transactions/self');
    switch (response) {
      case ContentListAPIResponse _:
        List<BearTransaction> result = [];
        for (var element in response.data) {
          element = element as Map<String, dynamic>;
          result.add(BearTransaction.fromJson(element));
        }
        return result;
      default:
        throw ErrorAPIResponse('Error in _getBearTransactionsSelf()');
    }
  }

  Future<bool> confirmTransaction(int transactionId) async {
    var response =
        await _apiClient.getProtected('/transactions/$transactionId/confirm');
    switch (response) {
      case ContentAPIResponse _:
        return true;
      default:
        throw ErrorAPIResponse('Error in confirmTransaction()');
    }
  }

  //
  // INTERNAL FUNCTIONS
  //

  Future<List<dynamic>> _getBearsByType(int bearTypeId) async {
    var response = await _apiClient.getProtected('/bear/types/$bearTypeId');
    switch (response) {
      case ContentListAPIResponse _:
        return response.data;
      default:
        throw ErrorAPIResponse('Error in _getBearsByType()');
    }
  }

  Future<List<BearType>> _getBearTypes() async {
    var response = await _apiClient.getProtected('/bear/types');
    switch (response) {
      case ContentListAPIResponse _:
        List<BearType> result = [];
        for (var element in response.data) {
          element = element as Map<String, dynamic>;
          result.add(BearType.fromJson(element));
        }
        return result;
      default:
        throw ErrorAPIResponse('Error in _getBearTypes()');
    }
  }
}
