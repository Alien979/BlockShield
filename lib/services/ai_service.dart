import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  late final String _apiKey;
  final String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  AIService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      print('Warning: GEMINI_API_KEY is not set in the .env file');
    }
  }

  Future<String> analyzeThreatData(
    String type,
    String description,
    String source,
    String impact,
    String targetSystems,
    String indicators,
    DateTime observationDate,
  ) async {
    final prompt = '''
    Analyze the following cyber threat data:
    Type: $type
    Description: $description
    Source: $source
    Potential Impact: $impact
    Target Systems/Software: $targetSystems
    Indicators of Compromise: $indicators
    Observation Date: ${observationDate.toIso8601String()}

    Please provide:
    1. A brief summary of the threat
    2. Potential severity rating (Low, Medium, High, Critical)
    3. Recommended immediate actions
    4. Long-term mitigation strategies
    5. Potential related threats or attack vectors
    6. Estimated financial impact range
    7. Recommended security controls to prevent similar threats
    ''';

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Unexpected response structure from Gemini API');
        }
      } else {
        throw Exception('Failed to analyze threat data: ${response.body}');
      }
    } catch (e) {
      print('Error in AI analysis: $e');
      return 'Error occurred during AI analysis: $e';
    }
  }

  Future<List<String>> correlateThreats(List<String> threatIds) async {
    final prompt = '''
    Analyze the following threat IDs and provide a list of potentially related threats:
    ${threatIds.join(', ')}

    Provide the IDs of related threats and a brief explanation for each correlation.
    ''';

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          return jsonResponse['candidates'][0]['content']['parts'][0]['text'].split('\n');
        } else {
          throw Exception('Unexpected response structure from Gemini API');
        }
      } else {
        throw Exception('Failed to correlate threats: ${response.body}');
      }
    } catch (e) {
      print('Error in AI threat correlation: $e');
      return ['Error occurred during AI threat correlation: $e'];
    }
  }
}