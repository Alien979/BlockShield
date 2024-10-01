import 'dart:convert';
import 'dart:html';
import 'package:crypto/crypto.dart';

class LocalBlockchainService {
  Future<Map<String, dynamic>> _readBlockchainData() async {
    try {
      String? contents = window.localStorage['local_blockchain'];
      return contents != null ? json.decode(contents) : {};
    } catch (e) {
      return {};
    }
  }

  Future<void> _writeBlockchainData(Map<String, dynamic> data) async {
    window.localStorage['local_blockchain'] = json.encode(data);
  }

  String _generateHash(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> submitThreatData(String id, Map<String, dynamic> threatData) async {
    var blockchainData = await _readBlockchainData();
    String hash = _generateHash(json.encode(threatData));
    blockchainData[id] = hash;
    await _writeBlockchainData(blockchainData);
    return true;
  }

  Future<bool> verifyThreatData(String id, Map<String, dynamic> threatData) async {
    var blockchainData = await _readBlockchainData();
    if (!blockchainData.containsKey(id)) {
      return false;
    }
    String storedHash = blockchainData[id];
    String currentHash = _generateHash(json.encode(threatData));
    return storedHash == currentHash;
  }
}