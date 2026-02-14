import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final themeColor = Color(appState.profile.favoriteColorValue);
    return Scaffold(
      backgroundColor: themeColor.withValues(alpha: 0.04),
      appBar: AppBar(
        title: const Text('📊 Mes progrès'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final progress = appState.progress;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCard(progress),
                const SizedBox(height: 20),
                _buildStreakCard(progress),
                const SizedBox(height: 20),
                _buildUnitsCard(context),
                const SizedBox(height: 20),
                if (progress.achievements.isNotEmpty) ...[
                  _buildAchievementsCard(progress),
                  const SizedBox(height: 20),
                ],
                _buildPathProgressCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(progress) {
    final cefrLevel = progress.cefrLevel as String;
    final cefrColors = {
      'A1-': const Color(0xFF66BB6A),
      'A1': const Color(0xFF4CAF50),
      'A1+': const Color(0xFF388E3C),
      'A2-': const Color(0xFFAED581),
      'A2': const Color(0xFF8BC34A),
      'A2+': const Color(0xFF689F38),
      'B1': const Color(0xFFFF9800),
      'B2': const Color(0xFFFF5722),
      'C1': const Color(0xFF9C27B0),
      'C2': const Color(0xFFE91E63),
    };
    final cefrThresholds = [0, 200, 500, 1000, 2000, 3500];
    final cefrLabels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final currentIdx = cefrLabels.indexOf(cefrLevel);
    final nextThreshold = currentIdx < 5 ? cefrThresholds[currentIdx + 1] : cefrThresholds[5];
    final currentThreshold = cefrThresholds[currentIdx];
    final progressToNext = currentIdx < 5
        ? ((progress.totalPoints - currentThreshold) / (nextThreshold - currentThreshold)).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cefrColors[cefrLevel] ?? const Color(0xFF3366CC),
            (cefrColors[cefrLevel] ?? const Color(0xFF3366CC)).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (cefrColors[cefrLevel] ?? const Color(0xFF3366CC)).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Mon niveau d\'anglais',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              cefrLevel,
              style: const TextStyle(
                fontSize: 52,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '⭐ ${progress.totalPoints} points au total',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (currentIdx < 5) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressToNext as double,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Prochain : ${cefrLabels[currentIdx + 1]}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakCard(progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem(
            '🔥',
            'Série actuelle',
            '${progress.currentStreak} jours',
            Colors.orange,
          ),
          Container(width: 1, height: 50, color: Colors.grey[300]),
          _buildStreakItem(
            '🏅',
            'Meilleure série',
            '${progress.bestStreak} jours',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem(String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsCard(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📚 Progression', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 24),
            const SizedBox(width: 12),
            Text('${appState.completedUnitsCount}/${appState.totalUnitsCount} leçons terminées', style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: appState.overallProgress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Succès',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...progress.achievements.map<Widget>((achievement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    _getAchievementName(achievement),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPathProgressCard(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final section = appState.currentSection;
    final chapter = appState.currentChapter;
    if (section == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📖 Parcours actuel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Text('Niveau : ${section.cefrLevel} — ${section.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          if (chapter != null) ...[const SizedBox(height: 4), Text('${chapter.emoji} ${chapter.title}', style: TextStyle(fontSize: 14, color: Colors.grey[600]))],
        ],
      ),
    );
  }

  String _getAchievementName(String id) {
    final names = {
      'first_lesson': '✅ Premier pas',
      'five_lessons': '✅ Apprenant motivé',
      'ten_lessons': '✅ Super élève',
      'streak_3': '✅ Régularité',
      'streak_7': '✅ Une semaine parfaite',
      'level_5': '✅ Niveau 5 atteint',
    };
    return names[id] ?? id;
  }

}
