/// Example integration of adaptive difficulty with existing lesson/quiz screens
/// This shows how to integrate the difficulty system into your app
library;


import 'package:flutter/material.dart';
import '../models/adaptive_difficulty.dart';
import '../models/learning.dart';
import '../services/difficulty_service.dart';
import '../widgets/difficulty_badge.dart';

/// Example: Enhanced Quiz Screen with Adaptive Difficulty
class AdaptiveLessonScreen extends StatefulWidget {
  final Lesson lesson;
  final UserSkillProfile skillProfile;
  final Function(UserSkillProfile) onProfileUpdated;

  const AdaptiveLessonScreen({
    Key? key,
    required this.lesson,
    required this.skillProfile,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<AdaptiveLessonScreen> createState() => _AdaptiveLessonScreenState();
}

class _AdaptiveLessonScreenState extends State<AdaptiveLessonScreen> {
  final DifficultyService _difficultyService = DifficultyService();
  
  late DifficultyLevel _currentDifficulty;
  late DateTime _lessonStartTime;
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _mistakeCount = 0;
  List<PerformanceRecord> _lessonAttempts = [];
  bool _showSkillUpMessage = false;
  String? _skillChangeMessage;

  @override
  void initState() {
    super.initState();
    _initializeDifficulty();
    _lessonStartTime = DateTime.now();
  }

  /// Get initial difficulty recommendation
  void _initializeDifficulty() {
    final recommendation = _difficultyService.getDifficultyRecommendation(
      topicId: widget.lesson.pathId,
      profile: widget.skillProfile,
    );
    
    _currentDifficulty = recommendation.suggestedLevel;
    
    // Show recommendation to user
    if (recommendation.confidence > 0.7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDifficultyRecommendation(recommendation);
      });
    }
  }

  /// Show difficulty recommendation dialog
  void _showDifficultyRecommendation(DifficultyRecommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommended Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DifficultyBadge(difficulty: recommendation.suggestedLevel),
            const SizedBox(height: 16),
            Text(recommendation.reason),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(recommendation.confidence * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Start Lesson'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDifficultySelector();
            },
            child: const Text('Change Difficulty'),
          ),
        ],
      ),
    );
  }

  /// Allow user to manually select difficulty
  void _showDifficultySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DifficultyLevel.values.map((level) {
            return ListTile(
              leading: Text(level.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(level.displayName),
              subtitle: Text(level.description),
              onTap: () {
                setState(() {
                  _currentDifficulty = level;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Handle answer submission
  void _submitAnswer(QuizQuestion question, int selectedIndex) {
    final isCorrect = selectedIndex == question.correctIndex;
    
    if (!isCorrect) {
      _mistakeCount++;
    } else {
      _score++;
    }

    // Record this attempt
    final attemptRecord = PerformanceRecord(
      timestamp: DateTime.now(),
      topicId: widget.lesson.pathId,
      difficulty: _currentDifficulty,
      score: isCorrect ? 1 : 0,
      maxScore: 1,
      mistakeCount: isCorrect ? 0 : 1,
      timeSpent: DateTime.now().difference(_lessonStartTime),
      completed: true,
    );
    
    _lessonAttempts.add(attemptRecord);

    // Check if we should adjust difficulty mid-lesson
    final newDifficulty = _difficultyService.checkForMidLessonAdjustment(
      currentDifficulty: _currentDifficulty,
      lessonAttempts: _lessonAttempts,
    );

    if (newDifficulty != null && newDifficulty != _currentDifficulty) {
      _showDifficultyAdjustment(_currentDifficulty, newDifficulty);
      setState(() {
        _currentDifficulty = newDifficulty;
      });
    }

    // Move to next question
    if (_currentQuestionIndex < (widget.lesson.quiz?.questions.length ?? 0) - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completLesson();
    }
  }

  /// Show difficulty adjustment notification
  void _showDifficultyAdjustment(DifficultyLevel oldLevel, DifficultyLevel newLevel) {
    final isIncrease = newLevel.index > oldLevel.index;
    final message = isIncrease
        ? 'Great job! Moving to ${newLevel.displayName}'
        : 'Let\'s build confidence at ${newLevel.displayName}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DifficultyChangeNotification(
          oldLevel: oldLevel,
          newLevel: newLevel,
          reason: message,
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  /// Complete lesson and update profile
  void _completLesson() {
    final totalTime = DateTime.now().difference(_lessonStartTime);
    final maxScore = widget.lesson.quiz?.questions.length ?? 0;

    // Create final performance record
    final lessonRecord = PerformanceRecord(
      timestamp: DateTime.now(),
      topicId: widget.lesson.pathId,
      difficulty: _currentDifficulty,
      score: _score,
      maxScore: maxScore,
      mistakeCount: _mistakeCount,
      timeSpent: totalTime,
      completed: true,
    );

    // Get old skill level for comparison
    final oldSkill = widget.skillProfile.getSkillLevel(widget.lesson.pathId);

    // Update profile
    var updatedProfile = _difficultyService.updateProfileAfterLesson(
      currentProfile: widget.skillProfile,
      lessonRecord: lessonRecord,
    );

    // Get new skill level
    final newSkill = updatedProfile.getSkillLevel(widget.lesson.pathId);

    // Check for skill change message
    _skillChangeMessage = _difficultyService.getSkillChangeMessage(
      oldSkill: oldSkill,
      newSkill: newSkill,
      topicName: widget.lesson.title,
    );

    // Update parent
    widget.onProfileUpdated(updatedProfile);

    // Show completion with skill feedback
    _showCompletionDialog();
  }

  /// Show lesson completion dialog
  void _showCompletionDialog() {
    final accuracy = widget.lesson.quiz != null
        ? (_score / widget.lesson.quiz!.questions.length * 100).toInt()
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lesson Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: $_score / ${widget.lesson.quiz?.questions.length ?? 0}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Accuracy: $accuracy%'),
            Text('Mistakes: $_mistakeCount'),
            const SizedBox(height: 16),
            DifficultyBadge(difficulty: _currentDifficulty),
            if (_skillChangeMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Text(
                  _skillChangeMessage!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to lessons
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Your existing lesson UI with difficulty badge at the top
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: DifficultyBadge(
                difficulty: _currentDifficulty,
                size: 0.9,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current skill level indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: SkillLevelIndicator(
              skillLevel: widget.skillProfile.getSkillLevel(widget.lesson.pathId),
              label: 'Your ${widget.lesson.title} Skill',
            ),
          ),
          
          // Quiz questions (your existing implementation)
          Expanded(
            child: _buildQuizContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    // Your existing quiz UI
    // This is just a placeholder
    return Center(
      child: Text('Quiz question ${_currentQuestionIndex + 1}'),
    );
  }
}

/// Example: How to persist UserSkillProfile
/// 
/// In your storage service, add these methods:
/// 
/// ```dart
/// class StorageService {
///   static const String _skillProfileKey = 'user_skill_profile';
///   
///   Future<void> saveSkillProfile(UserSkillProfile profile) async {
///     final prefs = await SharedPreferences.getInstance();
///     final json = jsonEncode(profile.toJson());
///     await prefs.setString(_skillProfileKey, json);
///   }
///   
///   Future<UserSkillProfile> loadSkillProfile() async {
///     final prefs = await SharedPreferences.getInstance();
///     final json = prefs.getString(_skillProfileKey);
///     
///     if (json == null) {
///       return UserSkillProfile.empty();
///     }
///     
///     return UserSkillProfile.fromJson(jsonDecode(json));
///   }
/// }
/// ```

/// Example: Main app integration
/// 
/// In your main app state:
/// ```dart
/// class _MyAppState extends State<MyApp> {
///   late UserSkillProfile _skillProfile;
///   final StorageService _storage = StorageService();
///   
///   @override
///   void initState() {
///     super.initState();
///     _loadSkillProfile();
///   }
///   
///   Future<void> _loadSkillProfile() async {
///     final profile = await _storage.loadSkillProfile();
///     setState(() {
///       _skillProfile = profile;
///     });
///   }
///   
///   void _updateSkillProfile(UserSkillProfile newProfile) {
///     setState(() {
///       _skillProfile = newProfile;
///     });
///     _storage.saveSkillProfile(newProfile);
///   }
///   
///   // Pass to lesson screens:
///   AdaptiveLessonScreen(
///     lesson: lesson,
///     skillProfile: _skillProfile,
///     onProfileUpdated: _updateSkillProfile,
///   )
/// }
/// ```
