import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/threat.dart';
import '../models/comment.dart';
import '../services/ai_service.dart';
import '../services/blockchain_service.dart';
import '../services/ethereum_service.dart';

class ThreatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService;
  final EthereumService _ethereumService;
  late BlockchainService _blockchainService;
  List<Threat> _threats = [];
  bool _isLoading = false;

  ThreatProvider(this._aiService, this._ethereumService);

  void setBlockchainService(BlockchainService service) {
    _blockchainService = service;
  }

  List<Threat> get threats => _threats;
  bool get isLoading => _isLoading;

  Future<void> fetchThreats() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('threats')
          .orderBy('timestamp', descending: true)
          .get();
      _threats = snapshot.docs.map((doc) => Threat.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching threats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addThreat(Threat threat) async {
    try {
      bool feeDeducted = await _ethereumService.deductSubmissionFee();
      if (!feeDeducted) {
        throw Exception('Insufficient balance to submit threat');
      }
      DocumentReference docRef = await _firestore.collection('threats').add(threat.toJson());
      
      DocumentSnapshot docSnap = await docRef.get();
      Threat newThreat = Threat.fromFirestore(docSnap);
      
      _threats.insert(0, newThreat);
      await _ethereumService.updateReputation(1); // Increase reputation for submitting a threat
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding threat: $e');
      return false;
    }
  }

  Future<void> updateThreatStatus(String threatId, String newStatus) async {
    try {
      await _firestore.collection('threats').doc(threatId).update({
        'status': newStatus,
      });
      
      int index = _threats.indexWhere((threat) => threat.id == threatId);
      if (index != -1) {
        _threats[index] = _threats[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating threat status: $e');
      rethrow;
    }
  }

  Future<bool> verifyThreat(String threatId) async {
    try {
      bool feeDeducted = await _ethereumService.deductVerificationFee();
      if (!feeDeducted) {
        throw Exception('Insufficient balance to verify threat');
      }

      DocumentSnapshot doc = await _firestore.collection('threats').doc(threatId).get();
      
      if (!doc.exists) {
        print('Threat not found: $threatId');
        return false;
      }

      Threat threat = Threat.fromFirestore(doc);
      
      bool added = await _blockchainService.addBlock(jsonEncode(threat.toJson()));
      
      if (added) {
        await _firestore.collection('threats').doc(threatId).update({
          'isVerified': true,
          'verificationTimestamp': FieldValue.serverTimestamp(),
        });
        
        int index = _threats.indexWhere((t) => t.id == threatId);
        if (index != -1) {
          _threats[index] = _threats[index].copyWith(
            isVerified: true,
            verificationTimestamp: DateTime.now(),
          );
        }
        
        await _ethereumService.updateReputation(2); // Increase reputation for verifying a threat
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying threat: $e');
      return false;
    }
  }

  List<Threat> getVerifiedThreats() {
    return _threats.where((threat) => threat.isVerified).toList();
  }

  Future<List<Comment>> getComments(String threatId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('threatId', isEqualTo: threatId)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<void> addComment(String threatId, String userId, String content) async {
    try {
      await _firestore.collection('comments').add({
        'threatId': threatId,
        'userId': userId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<List<String>> correlateThreats(String threatId) async {
    try {
      final threat = _threats.firstWhere((t) => t.id == threatId);
      final relatedThreats = await _aiService.correlateThreats([threat.id]);
      return relatedThreats;
    } catch (e) {
      print('Error correlating threats: $e');
      return [];
    }
  }

  Map<String, int> getThreatOverview() {
    return {
      'Active': _threats.where((t) => t.status == 'Active').length,
      'Resolved': _threats.where((t) => t.status == 'Resolved').length,
      'Pending': _threats.where((t) => t.status == 'Pending').length,
    };
  }

  List<Map<String, dynamic>> getThreatTrend(String timeRange) {
    DateTime now = DateTime.now();
    DateTime startDate;
    switch (timeRange.toLowerCase()) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(Duration(days: 30));
        break;
      case 'year':
        startDate = now.subtract(Duration(days: 365));
        break;
      default:
        startDate = now.subtract(Duration(days: 30));
    }

    List<Threat> filteredThreats = _threats.where((threat) => threat.timestamp.isAfter(startDate)).toList();
    
    Map<DateTime, int> threatsByDay = {};
    for (var threat in filteredThreats) {
      DateTime day = DateTime(threat.timestamp.year, threat.timestamp.month, threat.timestamp.day);
      threatsByDay[day] = (threatsByDay[day] ?? 0) + 1;
    }

    var sortedDays = threatsByDay.keys.toList()..sort();
    return sortedDays.map((day) => {
      'date': day.toIso8601String().split('T')[0],
      'count': threatsByDay[day],
    }).toList();
  }

  Map<String, int> getThreatTypeDistribution() {
    Map<String, int> distribution = {};
    for (var threat in _threats) {
      distribution[threat.type] = (distribution[threat.type] ?? 0) + 1;
    }
    return distribution;
  }

  List<Threat> getRecentThreats(int count) {
    return _threats.take(count).toList();
  }

  Map<String, int> getThreatSeverityDistribution() {
    Map<String, int> distribution = {};
    for (var threat in _threats) {
      distribution[threat.severity] = (distribution[threat.severity] ?? 0) + 1;
    }
    return distribution;
  }

  Future<int> getUserReputation() async {
    return await _ethereumService.getReputation();
  }
}