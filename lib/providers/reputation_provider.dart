import 'package:flutter/foundation.dart';
import '../services/ethereum_service.dart';

class ReputationProvider with ChangeNotifier {
  final EthereumService _ethereumService;
  int _reputation = 0;

  ReputationProvider(this._ethereumService);

  int get reputation => _reputation;

  Future<void> fetchReputation() async {
    try {
      _reputation = await _ethereumService.getReputation();
      notifyListeners();
    } catch (e) {
      print('Error fetching reputation: $e');
    }
  }

  Future<void> updateReputation(int change) async {
    try {
      await _ethereumService.updateReputation(change);
      await fetchReputation();
    } catch (e) {
      print('Error updating reputation: $e');
    }
  }
}