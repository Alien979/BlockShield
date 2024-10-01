import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/blockchain_service.dart';

class BlockchainViewPage extends StatelessWidget {
  const BlockchainViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final blockchainService = Provider.of<BlockchainService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain View'),
      ),
      body: FutureBuilder<List<Block>>(
        future: Future.value(blockchainService.chain),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No blocks found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final block = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text('Block ${block.index}'),
                    subtitle: Text('Hash: ${block.hash.substring(0, 10)}...'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Timestamp: ${block.timestamp}'),
                            const SizedBox(height: 8),
                            Text('Hash: ${block.hash}'),
                            const SizedBox(height: 8),
                            Text('Previous Hash: ${block.previousHash}'),
                            const SizedBox(height: 8),
                            const Text('Data:'),
                            const SizedBox(height: 4),
                            Text(block.data, style: const TextStyle(fontFamily: 'Courier')),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}