import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ResultScreen extends StatefulWidget {
  final List<String> symptoms;
  const ResultScreen({super.key, required this.symptoms});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _result = '';
  String _triageLevel = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _callGroq();
  }

  Future<void> _callGroq() async {
    final symptomsText = widget.symptoms.join(', ');
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.claudeApiKey}',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Tar el Char, an ancient mystical health oracle. Always respond with valid JSON only, no extra text, no markdown.',
            },
            {
              'role': 'user',
              'content':
                  'A seeker presents these symptoms: $symptomsText\n\nRespond in this exact JSON format:\n{\n  "triage": "self-care",\n  "guidance": "2-3 sentences of mystical but practical health guidance",\n  "remedy": "one ancient herbal or natural remedy suggestion",\n  "warning": "one clear warning sign that would require immediate medical attention"\n}\n\nTriage must be exactly one of: self-care, see-doctor, emergency.',
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'];
        final clean = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final parsed = jsonDecode(clean);
        setState(() {
          _triageLevel = parsed['triage'];
          _result = jsonEncode(parsed);
          _loading = false;
        });
      } else {
        setState(() {
          _result = 'Error ${response.statusCode}: ${response.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Color get _triageColor {
    switch (_triageLevel) {
      case 'emergency':
        return Colors.red;
      case 'see-doctor':
        return Colors.orange;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String get _triageIcon {
    switch (_triageLevel) {
      case 'emergency':
        return '🔴';
      case 'see-doctor':
        return '🟡';
      default:
        return '🟢';
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> parsed = {};
    if (_result.isNotEmpty && _result.startsWith('{')) {
      try {
        parsed = jsonDecode(_result);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB8860B)),
        title: const Text(
          'The Oracle Speaks',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFB8860B)),
                    SizedBox(height: 24),
                    Text(
                      'The grimoire stirs...',
                      style: TextStyle(
                        color: Color(0xFFB8860B),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your afflictions',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.symptoms
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFB8860B),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: Color(0xFFB8860B),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    if (parsed.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: _triageColor, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _triageIcon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _triageLevel.toUpperCase().replaceAll('-', ' '),
                              style: TextStyle(
                                color: _triageColor,
                                fontSize: 16,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _card(
                        '⚗ The Oracle\'s Guidance',
                        parsed['guidance'] ?? '',
                      ),
                      const SizedBox(height: 16),
                      _card('☽ Ancient Remedy', parsed['remedy'] ?? ''),
                      const SizedBox(height: 16),
                      _card(
                        '⚠ Seek a Healer If',
                        parsed['warning'] ?? '',
                        borderColor: Colors.orange,
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          _result,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    const Text(
                      '✦ This is not medical advice. Always consult a qualified healer for serious concerns.',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _card(
    String title,
    String content, {
    Color borderColor = const Color(0xFFB8860B),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: borderColor,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
