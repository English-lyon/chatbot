import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/lesson_content.dart';
import '../widgets/modern_button.dart';

class LessonsScreen extends StatelessWidget {
  final String moduleId;

  const LessonsScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final module = LessonContent.getModule(moduleId);
    
    if (module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Module not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: Text('${module.icon} ${module.name}'),
        backgroundColor: const Color(0xFF3366CC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: module.lessons.length,
            itemBuilder: (context, index) {
              final lesson = module.lessons[index];
              final isUnlocked = appState.isLessonUnlocked(lesson.level);
              final isCompleted = appState.progress.completedLessons.contains(lesson.id);

              return _buildLessonCard(
                context,
                lesson,
                isUnlocked,
                isCompleted,
                moduleId,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    Lesson lesson,
    bool isUnlocked,
    bool isCompleted,
    String moduleId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${lesson.level} • ${lesson.questions.length} questions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: isUnlocked
                  ? ModernButton(
                      text: 'Start ▶',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/quiz',
                          arguments: {'lesson': lesson, 'moduleId': moduleId},
                        );
                      },
                      backgroundColor: const Color(0xFF4CAF50),
                      fontSize: 14,
                      isSmall: true,
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Locked',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
