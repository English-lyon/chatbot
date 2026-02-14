import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/learning_path.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            if (appState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final sections = LearningPath.getSections();
            final allUnits = LearningPath.getAllUnitsFlat();
            final currentUnit = appState.currentUnit;

            // Find index of current unit to auto-scroll
            int currentIndex = 0;
            if (currentUnit != null) {
              currentIndex = allUnits.indexWhere((u) => u.id == currentUnit.id);
            }

            final themeColor = Color(appState.profile.favoriteColorValue);
            return Container(
              color: themeColor.withValues(alpha: 0.04),
              child: Column(
                children: [
                  _buildTopBar(context, appState),
                  Expanded(
                    child: _buildPath(context, appState, sections, currentIndex),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppState appState) {
    final section = appState.currentSection;
    final chapter = appState.currentChapter;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
                color: const Color(0xFF3366CC),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      section != null
                          ? '${section.cefrLevel} — ${section.title}'
                          : 'All Done! 🎉',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3366CC),
                      ),
                    ),
                    if (chapter != null)
                      Text(
                        '${chapter.emoji} ${chapter.title}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              _buildProgressBadge(appState),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: appState.overallProgress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${appState.completedUnitsCount} / ${appState.totalUnitsCount} units completed',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBadge(AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8F00),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '${appState.progress.totalPoints}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPath(BuildContext context, AppState appState,
      List<Section> sections, int currentUnitGlobalIndex) {
    // Build a flat list of widgets: section headers, chapter headers, and unit circles
    final items = <Widget>[];

    for (final section in sections) {
      items.add(_buildSectionHeader(section, appState));

      for (final chapter in section.chapters) {
        items.add(_buildChapterHeader(chapter, appState));

        for (int i = 0; i < chapter.units.length; i++) {
          final unit = chapter.units[i];
          items.add(_buildUnitNode(
            context,
            appState,
            unit,
            i,
            chapter.units.length,
          ));
        }
      }
    }

    // Add bottom padding
    items.add(const SizedBox(height: 80));

    // Create scroll controller to auto-scroll to current position
    final controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Rough estimate: scroll to current unit position
      if (currentUnitGlobalIndex > 2) {
        final offset = (currentUnitGlobalIndex * 130.0).clamp(0.0, double.infinity);
        if (controller.hasClients) {
          controller.animateTo(
            offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });

    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items,
    );
  }

  Widget _buildSectionHeader(Section section, AppState appState) {
    final progress = LearningPath.getSectionProgress(
        section.id, appState.progress.completedUnitIds);
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
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cefrColors[section.cefrLevel] ?? Colors.blue,
            (cefrColors[section.cefrLevel] ?? Colors.blue).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (cefrColors[section.cefrLevel] ?? Colors.blue).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              section.cefrLevel,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  section.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterHeader(Chapter chapter, AppState appState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 4),
      child: Row(
        children: [
          Text(chapter.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  chapter.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitNode(BuildContext context, AppState appState,
      PathUnit unit, int indexInChapter, int totalInChapter) {
    final isCompleted = appState.isUnitCompleted(unit.id);
    final isUnlocked = appState.isUnitUnlocked(unit.id);
    final isCurrent = !isCompleted && isUnlocked;

    // Zigzag offset: alternate left and right
    final zigzagOffset = (indexInChapter % 3 == 0)
        ? 0.0
        : (indexInChapter % 3 == 1)
            ? 40.0
            : -40.0;

    // Colors based on state
    Color circleColor;
    Color borderColor;
    Color textColor;
    if (isCompleted) {
      circleColor = const Color(0xFF4CAF50);
      borderColor = const Color(0xFF388E3C);
      textColor = Colors.white;
    } else if (isCurrent) {
      circleColor = const Color(0xFFFF8F00);
      borderColor = const Color(0xFFE65100);
      textColor = Colors.white;
    } else {
      circleColor = Colors.grey.shade300;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey.shade500;
    }

    // Icon based on unit type and state
    Widget iconWidget;
    if (isCompleted) {
      iconWidget = const Icon(Icons.check_rounded, color: Colors.white, size: 28);
    } else if (unit.type == UnitType.review) {
      iconWidget = Text('🏆', style: TextStyle(fontSize: 24, color: textColor));
    } else if (unit.type == UnitType.practice) {
      iconWidget = Icon(Icons.fitness_center_rounded, color: textColor, size: 24);
    } else {
      iconWidget = Text(unit.emoji, style: const TextStyle(fontSize: 24));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(zigzagOffset, 0),
            child: GestureDetector(
              onTap: isUnlocked
                  ? () => _startUnit(context, appState, unit)
                  : null,
              child: Column(
                children: [
                  // Connection line above (except first)
                  if (indexInChapter > 0)
                    Container(
                      width: 3,
                      height: 16,
                      color: isCompleted
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                    ),
                  // The circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isCurrent ? 72 : 64,
                    height: isCurrent ? 72 : 64,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: circleColor.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(child: iconWidget),
                  ),
                  const SizedBox(height: 4),
                  // Unit title
                  SizedBox(
                    width: 100,
                    child: Text(
                      unit.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isUnlocked
                            ? const Color(0xFF333333)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startUnit(BuildContext context, AppState appState, PathUnit unit) {
    Navigator.pushNamed(
      context,
      '/quiz',
      arguments: {'unit': unit},
    );
  }
}
