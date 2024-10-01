import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/threat_provider.dart';
import '../services/ai_service.dart';
import '../models/threat.dart';
import '../providers/user_provider.dart';

class DataSubmissionPage extends StatefulWidget {
  const DataSubmissionPage({super.key});

  @override
  _DataSubmissionPageState createState() => _DataSubmissionPageState();
}

class _DataSubmissionPageState extends State<DataSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  String _threatType = '';
  String _description = '';
  String _source = '';
  String _impact = '';
  String _targetSystems = '';
  String _indicators = '';
  String _severity = 'Low';
  DateTime _observationDate = DateTime.now();
  bool _isAnalyzing = false;
  String _aiAnalysis = '';

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AIService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Threat Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                label: 'Threat Type',
                value: _threatType,
                items: [
                  'Malware',
                  'Phishing',
                  'DDoS',
                  'SQL Injection',
                  'Other'
                ],
                onChanged: (value) => setState(() => _threatType = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Description',
                maxLines: 3,
                onChanged: (value) {
                  setState(() => _description = value!);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Source',
                onChanged: (value) => setState(() => _source = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Potential Impact',
                maxLines: 2,
                onChanged: (value) => setState(() => _impact = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Target Systems/Software',
                onChanged: (value) => setState(() => _targetSystems = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Indicators of Compromise',
                maxLines: 2,
                onChanged: (value) => setState(() => _indicators = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Severity',
                value: _severity,
                items: ['Low', 'Medium', 'High', 'Critical'],
                onChanged: (value) => setState(() => _severity = value!),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _analyzeData(aiService),
                child: const Text('Analyze Threat Data'),
              ),
              const SizedBox(height: 16),
              if (_isAnalyzing)
                const Center(child: CircularProgressIndicator())
              else if (_aiAnalysis.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Analysis:',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(_aiAnalysis),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Threat Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value.isEmpty ? null : value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null ? 'Please select a $label' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _observationDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _observationDate) {
          setState(() {
            _observationDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Observation Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_observationDate.toString().split(' ')[0]),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  void _analyzeData(AIService aiService) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isAnalyzing = true);

      try {
        final analysisResult = await aiService.analyzeThreatData(
          _threatType,
          _description,
          _source,
          _impact,
          _targetSystems,
          _indicators,
          _observationDate,
        );
        setState(() {
          _aiAnalysis = analysisResult;
          _isAnalyzing = false;
        });
      } catch (e) {
        setState(() {
          _aiAnalysis = 'Error during analysis: $e';
          _isAnalyzing = false;
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final submitterId = userProvider.user?.uid ?? 'unknown';

      final newThreat = Threat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _threatType,
        description: _description,
        timestamp: _observationDate,
        status: 'Active',
        source: _source,
        impact: _impact,
        targetSystems: _targetSystems,
        indicators: _indicators,
        aiAnalysis: _aiAnalysis,
        severity: _severity,
        submitterId: submitterId,
      );

      bool success = await context.read<ThreatProvider>().addThreat(newThreat);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Threat data submitted successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit threat. Insufficient balance.')),
        );
      }
    }
  }
}