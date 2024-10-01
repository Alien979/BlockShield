import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Block {
  final int index;
  final String timestamp;
  final String data;
  final String previousHash;
  late String hash;

  Block({
    required this.index,
    required this.timestamp,
    required this.data,
    required this.previousHash,
  }) {
    hash = calculateHash();
  }

  String calculateHash() {
    String blockData = '$index$timestamp$data$previousHash';
    return sha256.convert(utf8.encode(blockData)).toString();
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'timestamp': timestamp,
    'data': data,
    'previousHash': previousHash,
    'hash': hash,
  };

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      index: json['index'],
      timestamp: json['timestamp'],
      data: json['data'],
      previousHash: json['previousHash'],
    )..hash = json['hash'];
  }
}

class BlockchainService {
  List<Block> _chain = [];
  final String _storageKey = 'blockchain_data';

  BlockchainService() {
    _loadChain();
  }

  Future<void> _loadChain() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? chainJson = prefs.getString(_storageKey);
      if (chainJson != null) {
        final List<dynamic> jsonList = json.decode(chainJson);
        _chain = jsonList.map((blockJson) => Block.fromJson(blockJson)).toList();
      } else {
        // Create genesis block
        _chain.add(Block(
          index: 0,
          timestamp: DateTime.now().toIso8601String(),
          data: 'Genesis Block',
          previousHash: '0',
        ));
        await _saveChain();
      }
    } catch (e) {
      print('Error loading blockchain: $e');
    }
  }

  Future<void> _saveChain() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _chain.map((block) => block.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving blockchain: $e');
    }
  }

  Future<bool> addBlock(String data) async {
    Block previousBlock = _chain.last;
    Block newBlock = Block(
      index: previousBlock.index + 1,
      timestamp: DateTime.now().toIso8601String(),
      data: data,
      previousHash: previousBlock.hash,
    );
    _chain.add(newBlock);
    await _saveChain();
    return true;
  }

  bool isChainValid() {
    for (int i = 1; i < _chain.length; i++) {
      Block currentBlock = _chain[i];
      Block previousBlock = _chain[i - 1];

      if (currentBlock.hash != currentBlock.calculateHash()) {
        return false;
      }

      if (currentBlock.previousHash != previousBlock.hash) {
        return false;
      }
    }
    return true;
  }

  List<Block> get chain => _chain;
}