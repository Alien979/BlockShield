import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/threat_provider.dart';
import '../models/threat.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedTimeRange = 'Week';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThreatProvider>(context, listen: false).fetchThreats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlockShield Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ThreatProvider>(context, listen: false).fetchThreats();
            },
          ),
        ],
      ),
      body: Consumer<ThreatProvider>(
        builder: (context, threatProvider, child) {
          if (threatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThreatOverview(threatProvider),
                const SizedBox(height: 24),
                _buildTimeRangeSelector(),
                const SizedBox(height: 16),
                _buildThreatTrendChart(threatProvider),
                const SizedBox(height: 24),
                _buildThreatTypeDistribution(threatProvider),
                const SizedBox(height: 24),
                _buildRecentThreats(threatProvider),
                const SizedBox(height: 24),
                _buildThreatSeverityDistribution(threatProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThreatOverview(ThreatProvider provider) {
    final overview = provider.getThreatOverview();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Threat Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem('Active', overview['Active'] ?? 0, Colors.red),
                _buildOverviewItem('Resolved', overview['Resolved'] ?? 0, Colors.green),
                _buildOverviewItem('Pending', overview['Pending'] ?? 0, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(value: 'Week', label: Text('Week')),
        ButtonSegment<String>(value: 'Month', label: Text('Month')),
        ButtonSegment<String>(value: 'Year', label: Text('Year')),
      ],
      selected: <String>{_selectedTimeRange},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedTimeRange = newSelection.first;
        });
      },
    );
  }

  Widget _buildThreatTrendChart(ThreatProvider provider) {
    final trendData = provider.getThreatTrend(_selectedTimeRange.toLowerCase());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Threat Trend', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trendData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['count'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatTypeDistribution(ThreatProvider provider) {
    final distribution = provider.getThreatTypeDistribution();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Threat Type Distribution', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: distribution.entries.map((entry) {
                    return PieChartSectionData(
                      color: _getColorForThreatType(entry.key),
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      radius: 100,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentThreats(ThreatProvider provider) {
    final recentThreats = provider.getRecentThreats(5);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Threats', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentThreats.length,
              itemBuilder: (context, index) {
                final threat = recentThreats[index];
                return ListTile(
                  title: Text(threat.type),
                  subtitle: Text(threat.description),
                  trailing: Chip(
                    label: Text(threat.status),
                    backgroundColor: _getStatusColor(threat.status),
                  ),
                  onTap: () => Navigator.pushNamed(context, '/threat_detail', arguments: threat),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatSeverityDistribution(ThreatProvider provider) {
    final distribution = provider.getThreatSeverityDistribution();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Threat Severity Distribution', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: distribution.entries.map((entry) {
                    return PieChartSectionData(
                      color: _getColorForSeverity(entry.key),
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      radius: 100,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.red[100]!;
      case 'Resolved':
        return Colors.green[100]!;
      case 'Pending':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getColorForThreatType(String type) {
    switch (type) {
      case 'Malware':
        return Colors.red;
      case 'Phishing':
        return Colors.blue;
      case 'DDoS':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getColorForSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}