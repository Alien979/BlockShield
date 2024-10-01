import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/threat.dart';
import '../models/comment.dart';
import '../providers/threat_provider.dart';
import '../providers/user_provider.dart';

class ThreatDetailPage extends StatefulWidget {
  final Threat threat;

  const ThreatDetailPage({super.key, required this.threat});

  @override
  _ThreatDetailPageState createState() => _ThreatDetailPageState();
}

class _ThreatDetailPageState extends State<ThreatDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  List<String> _relatedThreats = [];
  bool _isVerifying = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _correlateThreats();
    _currentStatus = widget.threat.status;
  }

  Future<void> _loadComments() async {
    final comments = await Provider.of<ThreatProvider>(context, listen: false)
        .getComments(widget.threat.id);
    setState(() {
      _comments = comments;
    });
  }

  Future<void> _correlateThreats() async {
    final relatedThreats = await Provider.of<ThreatProvider>(context, listen: false)
        .correlateThreats(widget.threat.id);
    setState(() {
      _relatedThreats = relatedThreats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Threat Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${widget.threat.type}', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Description: ${widget.threat.description}'),
            SizedBox(height: 8),
            Text('Status: $_currentStatus'),
            SizedBox(height: 8),
            Text('Source: ${widget.threat.source}'),
            SizedBox(height: 8),
            Text('Impact: ${widget.threat.impact}'),
            SizedBox(height: 8),
            Text('Target Systems: ${widget.threat.targetSystems}'),
            SizedBox(height: 8),
            Text('Indicators: ${widget.threat.indicators}'),
            SizedBox(height: 8),
            Text('Severity: ${widget.threat.severity}'),
            SizedBox(height: 8),
            Text('Verified: ${widget.threat.isVerified ? 'Yes' : 'No'}'),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _currentStatus,
              items: ['Active', 'Pending', 'Resolved']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (newStatus) {
                if (newStatus != null) {
                  _updateThreatStatus(newStatus);
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOnBlockchain,
              child: _isVerifying
                  ? CircularProgressIndicator()
                  : Text('Verify on Blockchain'),
            ),
            SizedBox(height: 24),
            Text('AI Analysis:', style: Theme.of(context).textTheme.titleLarge),
            Text(widget.threat.aiAnalysis),
            SizedBox(height: 24),
            Text('Comments:', style: Theme.of(context).textTheme.titleLarge),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                  title: Text(comment.content),
                  subtitle: Text('By: ${comment.userId} on ${comment.timestamp}'),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Related Threats:', style: Theme.of(context).textTheme.titleLarge),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _relatedThreats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_relatedThreats[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addComment() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.uid;
    await Provider.of<ThreatProvider>(context, listen: false).addComment(
      widget.threat.id,
      userId,
      _commentController.text,
    );
    _commentController.clear();
    _loadComments();
  }

  void _verifyOnBlockchain() async {
    setState(() {
      _isVerifying = true;
    });
    try {
      final isVerified = await Provider.of<ThreatProvider>(context, listen: false).verifyThreat(widget.threat.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isVerified 
          ? 'Threat data verified successfully' 
          : 'Threat data verification failed')),
      );
      
      setState(() {
        widget.threat.isVerified = isVerified;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying threat data: $e')),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _updateThreatStatus(String newStatus) async {
    try {
      await Provider.of<ThreatProvider>(context, listen: false)
          .updateThreatStatus(widget.threat.id, newStatus);
      setState(() {
        _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Threat status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating threat status: $e')),
      );
    }
  }
}