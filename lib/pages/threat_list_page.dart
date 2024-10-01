import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/threat_provider.dart';
import '../models/threat.dart';
import 'threat_detail_page.dart';

class ThreatListPage extends StatefulWidget {
  const ThreatListPage({super.key});

  @override
  _ThreatListPageState createState() => _ThreatListPageState();
}

class _ThreatListPageState extends State<ThreatListPage> {
  String _filterStatus = 'All';
  String _sortBy = 'Date';
  String _searchQuery = '';

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
        title: const Text('All Threats'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String result) {
              setState(() {
                _filterStatus = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All Threats'),
              ),
              const PopupMenuItem<String>(
                value: 'Active',
                child: Text('Active Threats'),
              ),
              const PopupMenuItem<String>(
                value: 'Resolved',
                child: Text('Resolved Threats'),
              ),
              const PopupMenuItem<String>(
                value: 'Pending',
                child: Text('Pending Threats'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                _sortBy = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Date',
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem<String>(
                value: 'Type',
                child: Text('Sort by Type'),
              ),
              const PopupMenuItem<String>(
                value: 'Status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Threats',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<ThreatProvider>(
              builder: (context, threatProvider, child) {
                if (threatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (threatProvider.threats.isEmpty) {
                  return const Center(child: Text('No threats found'));
                }

                var filteredThreats = _filterThreats(threatProvider.threats);
                var sortedThreats = _sortThreats(filteredThreats);
                var searchedThreats = _searchThreats(sortedThreats);

                return RefreshIndicator(
                  onRefresh: () => threatProvider.fetchThreats(),
                  child: ListView.builder(
                    itemCount: searchedThreats.length,
                    itemBuilder: (context, index) {
                      final threat = searchedThreats[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(
                            threat.type,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(threat.description),
                              const SizedBox(height: 4),
                              Text(
                                'Reported: ${_formatDate(threat.timestamp)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: _getStatusChip(threat.status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ThreatDetailPage(threat: threat),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Threat> _filterThreats(List<Threat> threats) {
    if (_filterStatus == 'All') {
      return threats;
    }
    return threats.where((threat) => threat.status == _filterStatus).toList();
  }

  List<Threat> _sortThreats(List<Threat> threats) {
    switch (_sortBy) {
      case 'Date':
        return threats..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      case 'Type':
        return threats..sort((a, b) => a.type.compareTo(b.type));
      case 'Status':
        return threats..sort((a, b) => a.status.compareTo(b.status));
      default:
        return threats;
    }
  }

  List<Threat> _searchThreats(List<Threat> threats) {
    if (_searchQuery.isEmpty) {
      return threats;
    }
    return threats.where((threat) =>
      threat.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      threat.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      threat.source.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Widget _getStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.red;
        break;
      case 'Resolved':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}