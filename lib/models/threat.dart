import 'package:cloud_firestore/cloud_firestore.dart';

class Threat {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String status;
  final String source;
  final String impact;
  final String targetSystems;
  final String indicators;
  final String aiAnalysis;
  final String severity;
  final String submitterId;
  bool isVerified;
  DateTime? verificationTimestamp;

  Threat({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.status,
    this.source = '',
    this.impact = '',
    this.targetSystems = '',
    this.indicators = '',
    this.aiAnalysis = '',
    required this.severity,
    required this.submitterId,
    this.isVerified = false,
    this.verificationTimestamp,
  });

  factory Threat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Threat(
      id: doc.id,
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      timestamp: _parseDateTime(data['timestamp']),
      status: data['status'] ?? 'Active',
      source: data['source'] ?? '',
      impact: data['impact'] ?? '',
      targetSystems: data['targetSystems'] ?? '',
      indicators: data['indicators'] ?? '',
      aiAnalysis: data['aiAnalysis'] ?? '',
      severity: data['severity'] ?? 'Low',
      submitterId: data['submitterId'] ?? 'unknown',
      isVerified: data['isVerified'] ?? false,
      verificationTimestamp: _parseDateTime(data['verificationTimestamp']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'source': source,
      'impact': impact,
      'targetSystems': targetSystems,
      'indicators': indicators,
      'aiAnalysis': aiAnalysis,
      'severity': severity,
      'submitterId': submitterId,
      'isVerified': isVerified,
      'verificationTimestamp': verificationTimestamp?.toIso8601String(),
    };
  }

  Threat copyWith({
    String? id,
    String? type,
    String? description,
    DateTime? timestamp,
    String? status,
    String? source,
    String? impact,
    String? targetSystems,
    String? indicators,
    String? aiAnalysis,
    String? severity,
    String? submitterId,
    bool? isVerified,
    DateTime? verificationTimestamp,
  }) {
    return Threat(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      source: source ?? this.source,
      impact: impact ?? this.impact,
      targetSystems: targetSystems ?? this.targetSystems,
      indicators: indicators ?? this.indicators,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      severity: severity ?? this.severity,
      submitterId: submitterId ?? this.submitterId,
      isVerified: isVerified ?? this.isVerified,
      verificationTimestamp: verificationTimestamp ?? this.verificationTimestamp,
    );
  }
}