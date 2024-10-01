import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/ethereum_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _ethereumAddress;
  final AuthService _authService = AuthService();
  final EthereumService _ethereumService;

  UserProvider(this._ethereumService) {
    _authService.user.listen((User? user) {
      _user = user;
      if (user != null) {
        _generateEthereumAddress();
      } else {
        _ethereumAddress = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  String? get ethereumAddress => _ethereumAddress;

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      await _authService.registerWithEmailAndPassword(email, password);
      await updateProfile(displayName);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> updateProfile(String displayName) async {
    try {
      await _user?.updateDisplayName(displayName);
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> _generateEthereumAddress() async {
    _ethereumAddress = await _ethereumService.generateAddress();
    notifyListeners();
  }
}