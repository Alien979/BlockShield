import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/threat_provider.dart';
import '../models/threat.dart';

class VerifiedThreatsPage extends StatelessWidget {
  const VerifiedThreatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verified Threats'),
      ),
      body: Consumer<ThreatProvider>(
        builder: (context, threatProvider, child) {
          List<Threat> verifiedThreats = threatProvider.getVerifiedThreats();
          
          if (verifiedThreats.isEmpty) {
            return Center(child: Text('No verified threats yet.'));
          }
          
          return ListView.builder(
            itemCount: verifiedThreats.length,
            itemBuilder: (context, index) {
              Threat threat = verifiedThreats[index];
              return ListTile(
                title: Text(threat.type),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(threat.description),
                    Text('Verified on: ${threat.verificationTimestamp ?? "Unknown"}'),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/threat_detail', arguments: threat);
                },
              );
            },
          );
        },
      ),
    );
  }
}