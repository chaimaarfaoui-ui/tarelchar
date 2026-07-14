import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'herbalists.dart';

class ResultScreen extends StatefulWidget {
  final String mode; // 'symptoms' or 'medicine'
  final List<String>? symptoms;
  final String? medicine;

  const ResultScreen({
    super.key,
    this.mode = 'symptoms',
    this.symptoms,
    this.medicine,
  });

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
    try {
      final Map<String, dynamic> body = widget.mode == 'medicine'
          ? {'mode': 'medicine', 'medicine': widget.medicine ?? ''}
          : {'mode': 'symptoms', 'symptoms': widget.symptoms ?? []};

      final response = await http.post(
        Uri.parse('https://tar-el-char-api.vercel.app/api/consult-oracle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        setState(() {
          _triageLevel = parsed['triage'];
          _result = jsonEncode(parsed);
          _loading = false;
        });
        _saveConsultation(parsed);
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

  Future<void> _saveConsultation(Map<String, dynamic> parsed) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('consultations')
          .add({
            'mode': widget.mode,
            'symptoms': widget.symptoms,
            'medicine': widget.medicine,
            'triage': parsed['triage'],
            'guidance': parsed['guidance'],
            'remedy': parsed['remedy'],
            'herbName': parsed['herbName'],
            'herbDescription': parsed['herbDescription'],
            'warning': parsed['warning'],
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Failed to save consultation: $e');
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    final herbName = parsed['herbName'] ?? parsed['remedy'] ?? '';

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
                    Text(
                      widget.mode == 'medicine'
                          ? 'Your inquiry'
                          : 'Your afflictions',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.mode == 'medicine')
                      Container(
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
                          widget.medicine ?? '',
                          style: const TextStyle(
                            color: Color(0xFFB8860B),
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (widget.symptoms ?? [])
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
                      if (parsed['herbDescription'] != null) ...[
                        const SizedBox(height: 16),
                        _card('🌿 About This Herb', parsed['herbDescription']),
                      ],
                      const SizedBox(height: 16),
                      _card(
                        '⚠ Seek a Healer If',
                        parsed['warning'] ?? '',
                        borderColor: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      _herbalistSection(herbName),
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

  Widget _herbalistSection(String herbName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📍 Nearby Herbalists',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...tunisianHerbalists.take(3).map((h) => _herbalistTile(h, herbName)),
        const SizedBox(height: 20),
        const Text(
          '🛒 Order Online',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...onlineHerbalists.map((h) => _herbalistTile(h, herbName)),
      ],
    );
  }

  Widget _herbalistTile(Herbalist h, String herbName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB8860B), width: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  h.city,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          if (h.isOnline)
            TextButton(
              onPressed: () => _openLink(h.searchUrlForHerb(herbName)),
              child: const Text(
                'Find it →',
                style: TextStyle(color: Color(0xFFB8860B), fontSize: 12),
              ),
            )
          else
            TextButton(
              onPressed: () => _openLink(h.mapsUrl),
              child: const Text(
                'Map →',
                style: TextStyle(color: Color(0xFFB8860B), fontSize: 12),
              ),
            ),
        ],
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
