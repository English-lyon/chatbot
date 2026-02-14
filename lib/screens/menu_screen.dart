import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/learning_path.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            if (appState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final themeColor = Color(appState.profile.favoriteColorValue);
            return Container(
              color: themeColor.withValues(alpha: 0.04),
              child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildHeader(context, appState),
                  const SizedBox(height: 20),
                  _buildStats(appState),
                  const SizedBox(height: 24),
                  _buildBigPlayCard(context, appState, themeColor),
                  const SizedBox(height: 16),
                  _buildProgressBar(appState),
                  const SizedBox(height: 24),
                  _buildBottomButtons(context),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    final profile = appState.profile;
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Color(profile.favoriteColorValue).withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(profile.favoriteColorValue).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salut ${profile.name} ! 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Text(
                  'Prêt à apprendre l\'anglais ?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7799DD),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AppState appState) {
    final cefrLevel = appState.progress.cefrLevel;
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cefrColors[cefrLevel] ?? const Color(0xFF6B9BD1),
            (cefrColors[cefrLevel] ?? const Color(0xFF6B9BD1)).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (cefrColors[cefrLevel] ?? const Color(0xFF6B9BD1)).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCefrBadge(cefrLevel, cefrColors),
          _buildStatItem('Points', '${appState.progress.totalPoints}', Icons.emoji_events),
          _buildStatItem('Série', '${appState.progress.currentStreak} 🔥', Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildCefrBadge(String cefrLevel, Map<String, Color> colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cefrLevel,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Mon niveau',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildBigPlayCard(BuildContext context, AppState appState, Color themeColor) {
    final section = appState.currentSection;
    final chapter = appState.currentChapter;
    final unit = appState.currentUnit;

    if (unit == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: 60)),
            SizedBox(height: 12),
            Text('Félicitations !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Tu as terminé toutes les leçons !', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/quiz', arguments: {'unit': unit}),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor, themeColor.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(unit.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              unit.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${section?.cefrLevel ?? ''} • ${chapter?.emoji ?? ''} ${chapter?.title ?? ''}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            if (unit.type == UnitType.review)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🏆 Révision du chapitre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, child) {
                return Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: _glowAnim.value),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withValues(alpha: _glowAnim.value),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, size: 56, color: Color(0xFFFF8F00)),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text('▶ APPUIE POUR JOUER !', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(AppState appState) {
    final progress = appState.overallProgress;
    final section = appState.currentSection;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                section != null ? '${section.cefrLevel} \u2014 ${section.title}' : 'Tout fini !',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4CAF50)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${appState.completedUnitsCount} / ${appState.totalUnitsCount} leçons terminées',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            icon: const Text('🐻', style: TextStyle(fontSize: 18)),
            label: const Text('Copain', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8F00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/progress'),
            icon: const Icon(Icons.bar_chart_rounded, size: 20),
            label: const Text('Progrès', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
