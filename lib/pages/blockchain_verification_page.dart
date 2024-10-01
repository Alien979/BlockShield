import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/threat_provider.dart';
import '../models/threat.dart';

class BlockchainVerificationPage extends StatelessWidget {
  const BlockchainVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Verification'),
      ),
      body: Consumer<ThreatProvider>(
        builder: (context, threatProvider, child) {
          if (threatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: threatProvider.threats.length,
            itemBuilder: (context, index) {
              final threat = threatProvider.threats[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(threat.type),
                  subtitle: Text(threat.description),
                  trailing: threat.isVerified
                      ? const Icon(Icons.verified, color: Colors.green)
                      : ElevatedButton(
                          child: const Text('Verify'),
                          onPressed: () => _verifyThreat(context, threatProvider, threat.id),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _verifyThreat(BuildContext context, ThreatProvider provider, String threatId) async {
    try {
      bool verified = await provider.verifyThreat(threatId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verified ? 'Threat verified successfully' : 'Failed to verify threat'),
          backgroundColor: verified ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying threat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}