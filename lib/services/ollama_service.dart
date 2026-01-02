// lib/src/services/ollama_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class OllamaService {
  final String baseUrl;
  final String modelName;

  OllamaService({
    required this.baseUrl,
    required this.modelName,
  });

  /// Check if Ollama server is reachable
  Future<bool> checkConnection() async {
    try {
      // Remove '/api/generate' from baseUrl for connection check
      String checkUrl = baseUrl.replaceAll('/api/generate', '');
      final response = await http.get(
        Uri.parse('$checkUrl/api/tags'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }

  /// Get triage response from Ollama
  Future<String> getTriageResponse(
      String userInput,
      List<Map<String, String>> conversationHistory,
      ) async {
    try {
      // Build the prompt with conversation context
      String prompt = _buildTriagePrompt(userInput, conversationHistory);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': modelName,
          'prompt': prompt,
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_p': 0.9,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] ?? 'I apologize, I could not process that.';
      } else {
        return 'Sorry, I encountered an error. Status: ${response.statusCode}';
      }
    } catch (e) {
      print('Error getting triage response: $e');
      return 'I apologize, but I\'m having trouble connecting right now. Please try again.';
    }
  }

  /// Build medical triage prompt with context
  String _buildTriagePrompt(
      String userInput,
      List<Map<String, String>> history,
      ) {
    StringBuffer prompt = StringBuffer();

    // System prompt for medical triage
    prompt.writeln('''
You are a medical triage assistant. Your role is to:
1. Ask relevant questions about symptoms
2. Assess severity and urgency
3. Provide general guidance (not diagnosis)
4. Recommend when to seek immediate care

Be empathetic, clear, and concise. Always err on the side of caution.

Previous conversation:
''');

    // Add conversation history (last 5 exchanges)
    int startIdx = history.length > 10 ? history.length - 10 : 0;
    for (int i = startIdx; i < history.length; i++) {
      String role = history[i]['role'] == 'user' ? 'Patient' : 'Assistant';
      prompt.writeln('$role: ${history[i]['content']}');
    }

    // Add current user input
    prompt.writeln('\nPatient: $userInput');
    prompt.writeln('\nAssistant:');

    return prompt.toString();
  }

  /// Get streaming response (for future use)
  Stream<String> getTriageResponseStream(
      String userInput,
      List<Map<String, String>> conversationHistory,
      ) async* {
    try {
      String prompt = _buildTriagePrompt(userInput, conversationHistory);

      final request = http.Request('POST', Uri.parse(baseUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode({
        'model': modelName,
        'prompt': prompt,
        'stream': true,
        'options': {
          'temperature': 0.7,
          'top_p': 0.9,
        }
      });

      final streamedResponse = await request.send();

      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        try {
          final data = json.decode(chunk);
          if (data['response'] != null && data['response'].toString().isNotEmpty) {
            yield data['response'].toString();
          }
        } catch (e) {
          // Handle partial JSON chunks
          continue;
        }
      }
    } catch (e) {
      yield 'Error: Unable to get response';
    }
  }

  /// Get available models from Ollama
  Future<List<String>> getAvailableModels() async {
    try {
      String checkUrl = baseUrl.replaceAll('/api/generate', '');
      final response = await http.get(
        Uri.parse('$checkUrl/api/tags'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> models = [];
        if (data['models'] != null) {
          for (var model in data['models']) {
            models.add(model['name'] ?? '');
          }
        }
        return models;
      }
      return [];
    } catch (e) {
      print('Error getting models: $e');
      return [];
    }
  }

  /// Generate medical summary from conversation
  Future<Map<String, dynamic>> generateSummary(
      List<Map<String, String>> conversationHistory,
      ) async {
    try {
      String summaryPrompt = '''
Based on this medical triage conversation, provide a structured summary:

Conversation:
${conversationHistory.map((msg) => '${msg['role']}: ${msg['content']}').join('\n')}

Provide a JSON response with:
- chief_complaint: main symptom/concern
- severity: low/medium/high/emergency
- symptoms: list of symptoms mentioned
- duration: how long symptoms have been present
- recommendation: brief action recommendation

JSON:
''';

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': modelName,
          'prompt': summaryPrompt,
          'stream': false,
          'format': 'json',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String responseText = data['response'] ?? '{}';
        return json.decode(responseText);
      }

      return {};
    } catch (e) {
      print('Error generating summary: $e');
      return {};
    }
  }
}
