import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ethereum_service.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  EtherAmount? _balance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final ethereumService = Provider.of<EthereumService>(context, listen: false);
      final balance = await ethereumService.getBalance();
      setState(() {
        _balance = balance;
      });
    } catch (e) {
      print('Error fetching balance: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetBalance() async {
    final ethereumService = Provider.of<EthereumService>(context, listen: false);
    await ethereumService.resetBalance();
    await _fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlockShield Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildActionTiles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome to BlockShield',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Your decentralized threat intelligence platform',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Account Balance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    '${_balance?.getValueInUnit(EtherUnit.ether).toStringAsFixed(2) ?? "Loading..."} ETH',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _fetchBalance,
                  child: const Text('Refresh Balance'),
                ),
                ElevatedButton(
                  onPressed: _resetBalance,
                  child: const Text('Reset Balance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTiles() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildAnimatedTile(
          title: 'Dashboard',
          icon: Icons.dashboard,
          onTap: () => Navigator.pushNamed(context, '/dashboard'),
        ),
        _buildAnimatedTile(
          title: 'Submit Threat',
          icon: Icons.add_alert,
          onTap: () => Navigator.pushNamed(context, '/submit'),
        ),
        _buildAnimatedTile(
          title: 'Verify Threats',
          icon: Icons.verified_user,
          onTap: () => Navigator.pushNamed(context, '/verify'),
        ),
        _buildAnimatedTile(
          title: 'All Threats',
          icon: Icons.list,
          onTap: () => Navigator.pushNamed(context, '/threats'),
        ),
        _buildAnimatedTile(
          title: 'View Blockchain',
          icon: Icons.view_list,
          onTap: () => Navigator.pushNamed(context, '/blockchain_view'),
        ),
      ],
    );
  }

  Widget _buildAnimatedTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}