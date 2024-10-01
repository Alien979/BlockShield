import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EthereumService {
  late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _address;
  static const String _balanceKey = 'user_balance';
  static const String _reputationKey = 'user_reputation';
  static const double _initialBalance = 100.0;
  static const double _submissionFee = 0.1;
  static const double _verificationFee = 0.05;

  Future<void> initialize() async {
    _client = Web3Client('http://localhost:8545', Client());
    await _generateCredentials();
    await _initializeBalance();
    await _initializeReputation();
    print('EthereumService initialized successfully');
  }

  Future<void> _generateCredentials() async {
    final random = Random.secure();
    _credentials = EthPrivateKey.createRandom(random);
    _address = await _credentials.extractAddress();
  }

  Future<String> generateAddress() async {
    return _address.hexEip55;
  }

  Future<void> _initializeBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_balanceKey)) {
      await prefs.setDouble(_balanceKey, _initialBalance);
    }
  }

  Future<void> _initializeReputation() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_reputationKey)) {
      await prefs.setInt(_reputationKey, 0);
    }
  }

  Future<EtherAmount> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getDouble(_balanceKey) ?? _initialBalance;
    return EtherAmount.fromUnitAndValue(EtherUnit.ether, (balance * 1e18).toInt());
  }

  Future<bool> deductSubmissionFee() async {
    return _deductFee(_submissionFee);
  }

  Future<bool> deductVerificationFee() async {
    return _deductFee(_verificationFee);
  }

  Future<bool> _deductFee(double fee) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBalance = prefs.getDouble(_balanceKey) ?? _initialBalance;
    if (currentBalance >= fee) {
      final newBalance = currentBalance - fee;
      await prefs.setDouble(_balanceKey, newBalance);
      return true;
    }
    return false;
  }

  Future<void> resetBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, _initialBalance);
  }

  Future<int> getReputation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reputationKey) ?? 0;
  }

  Future<void> updateReputation(int change) async {
    final prefs = await SharedPreferences.getInstance();
    final currentReputation = prefs.getInt(_reputationKey) ?? 0;
    final newReputation = currentReputation + change;
    await prefs.setInt(_reputationKey, newReputation);
  }
}