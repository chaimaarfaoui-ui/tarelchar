import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Color _triageColor(String? triage) {
    switch (triage) {
      case 'emergency':
        return Colors.red;
      case 'see-doctor':
        return Colors.orange;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _triageIcon(String? triage) {
    switch (triage) {
      case 'emergency':
        return '🔴';
      case 'see-doctor':
        return '🟡';
      default:
        return '🟢';
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB8860B)),
        title: const Text(
          'The Grimoire Remembers',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Sign in to view your consultations.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('consultations')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB8860B)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'The grimoire is silent: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No consultations yet.\nYour past inquiries will appear here.',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _historyTile(data);
                  },
                );
              },
            ),
    );
  }

  Widget _historyTile(Map<String, dynamic> data) {
    final mode = data['mode'] ?? 'symptoms';
    final triage = data['triage'] as String?;
    final guidance = data['guidance'] as String? ?? '';
    final remedy = data['remedy'] as String? ?? '';
    final herbDescription = data['herbDescription'] as String?;
    final warning = data['warning'] as String? ?? '';
    final createdAt = data['createdAt'] as Timestamp?;

    String subtitle;
    if (mode == 'medicine') {
      subtitle = data['medicine'] ?? '';
    } else {
      final symptoms = (data['symptoms'] as List?)?.cast<String>() ?? [];
      subtitle = symptoms.join(', ');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: _triageColor(triage).withValues(alpha: 0.4),
          width: 0.6,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFFB8860B),
          iconColor: const Color(0xFFB8860B),
          title: Row(
            children: [
              Text(_triageIcon(triage), style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _detailBlock('⚗ Guidance', guidance),
            const SizedBox(height: 10),
            _detailBlock('☽ Remedy', remedy),
            if (herbDescription != null && herbDescription.isNotEmpty) ...[
              const SizedBox(height: 10),
              _detailBlock('🌿 About the Herb', herbDescription),
            ],
            const SizedBox(height: 10),
            _detailBlock('⚠ Warning', warning, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _detailBlock(String title, String content, {Color? color}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color ?? const Color(0xFFB8860B),
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
