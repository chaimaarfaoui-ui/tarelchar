import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_strings.dart';

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
        title: Text(
          AppStrings.t('grimoireRemembers'),
          style: const TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: user == null
          ? Center(
              child: Text(
                AppStrings.t('signInToView'),
                style: const TextStyle(color: Colors.white54),
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
                      '${AppStrings.t('grimoireSilent')}: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        AppStrings.t('noConsultationsYet'),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
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
    final reflectionNote = data['reflectionNote'] as String?;
    final rating = (data['rating'] as num?)?.toInt() ?? 0;
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
              if (rating > 0) _miniStars(rating),
              if (reflectionNote != null && reflectionNote.trim().isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text('📝', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _detailBlock(AppStrings.t('historyGuidance'), guidance),
            const SizedBox(height: 10),
            _detailBlock(AppStrings.t('historyRemedy'), remedy),
            if (herbDescription != null && herbDescription.isNotEmpty) ...[
              const SizedBox(height: 10),
              _detailBlock(AppStrings.t('historyHerbInfo'), herbDescription),
            ],
            const SizedBox(height: 10),
            _detailBlock(
              AppStrings.t('historyWarning'),
              warning,
              color: Colors.orange,
            ),
            if (rating > 0) ...[
              const SizedBox(height: 10),
              _ratingBlock(rating),
            ],
            if (reflectionNote != null && reflectionNote.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _reflectionBlock(reflectionNote),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: const Color(0xFFB8860B),
          size: 12,
        );
      }),
    );
  }

  Widget _ratingBlock(int rating) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t('yourRating'),
            style: const TextStyle(
              color: Color(0xFFB8860B),
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (i) {
              final filled = i < rating;
              return Icon(
                filled ? Icons.star : Icons.star_border,
                color: const Color(0xFFB8860B),
                size: 18,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _reflectionBlock(String content) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFB8860B).withValues(alpha: 0.06),
          border: Border.all(
            color: const Color(0xFFB8860B).withValues(alpha: 0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t('yourReflection'),
              style: const TextStyle(
                color: Color(0xFFB8860B),
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
                fontStyle: FontStyle.italic,
              ),
            ),
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
