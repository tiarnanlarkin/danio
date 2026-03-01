// Story player screen - Interactive narrative experience
// Full-screen Duolingo-style story interface with animations

library;
import 'package:danio/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story.dart';
import '../widgets/core/bubble_loader.dart';
import '../models/user_profile.dart';
import '../data/stories.dart';
import '../providers/user_profile_provider.dart';

class StoryPlayerScreen extends ConsumerStatefulWidget {
  final String storyId;

  const StoryPlayerScreen({super.key, required this.storyId});

  @override
  ConsumerState<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends ConsumerState<StoryPlayerScreen>
    with TickerProviderStateMixin {
  Story? _story;
  StoryProgress? _progress;
  StoryScene? _currentScene;
  bool _showingFeedback = false;
  String? _feedbackMessage;
  bool? _isCorrectChoice;
  late AnimationController _textAnimationController;
  late Animation<double> _textOpacity;
  late AnimationController _choiceAnimationController;
  late Animation<Offset> _choiceSlideAnimation;

  @override
  void initState() {
    super.initState();
    _loadStory();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Text fade-in animation
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: AppCurves.standard,
      ),
    );

    // Choice slide-up animation
    _choiceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _choiceSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _choiceAnimationController,
            curve: AppCurves.emphasized,
          ),
        );

    _textAnimationController.forward();
    _choiceAnimationController.forward();
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _choiceAnimationController.dispose();
    super.dispose();
  }

  void _loadStory() {
    _story = Stories.getById(widget.storyId);
    if (_story == null) return;

    // Check if there's existing progress
    final profile = ref.read(userProfileProvider).value;
    if (profile != null) {
      final progressJson = profile.storyProgress[widget.storyId];
      if (progressJson != null && progressJson is Map<String, dynamic>) {
        _progress = StoryProgress.fromJson(progressJson);
        _currentScene = _story!.getSceneById(_progress!.currentSceneId);
      }
    }

    // Start new if no progress
    if (_progress == null) {
      _progress = StoryProgress.start(widget.storyId, _story!.startScene.id);
      _currentScene = _story!.startScene;
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    if (_progress == null) return;

    final notifier = ref.read(userProfileProvider.notifier);
    final xpReward = _progress!.completed
        ? _progress!.calculateXp(_story!.xpReward)
        : 0;

    await notifier.updateStoryProgress(
      storyId: widget.storyId,
      progressData: _progress!.toJson(),
      isCompleted: _progress!.completed,
      xpReward: xpReward,
    );
  }

  void _makeChoice(StoryChoice choice) async {
    // Show feedback
    setState(() {
      _showingFeedback = true;
      _feedbackMessage = choice.feedback;
      _isCorrectChoice = choice.isCorrect;
    });

    // Wait for user to read feedback
    await Future.delayed(const Duration(seconds: 2));

    // Check if story ends
    if (choice.endsStory || _currentScene?.isFinalScene == true) {
      _completeStory(choice);
      return;
    }

    // Move to next scene
    final nextScene = _story!.getSceneById(choice.nextSceneId);
    if (nextScene == null) {
      _completeStory(choice);
      return;
    }

    setState(() {
      _progress = _progress!.makeChoice(
        choice: choice,
        nextSceneId: choice.nextSceneId,
        isFinalScene: nextScene.isFinalScene,
      );
      _currentScene = nextScene;
      _showingFeedback = false;
      _feedbackMessage = null;
      _isCorrectChoice = null;
    });

    // Restart animations for new scene
    _textAnimationController.reset();
    _choiceAnimationController.reset();
    _textAnimationController.forward();
    _choiceAnimationController.forward();

    await _saveProgress();
  }

  void _completeStory(StoryChoice finalChoice) async {
    setState(() {
      _progress = _progress!.makeChoice(
        choice: finalChoice,
        nextSceneId: '',
        isFinalScene: true,
      );
    });

    await _saveProgress();

    if (!mounted) return;

    // Show completion dialog
    final xpEarned = _progress!.calculateXp(_story!.xpReward);
    _showCompletionDialog(xpEarned);
  }

  void _showCompletionDialog(int xpEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(children: [const Text('🎉 Story Complete!')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentScene?.successMessage ?? 'Well done!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppOverlays.amber20,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    '+$xpEarned XP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Score: ${_progress!.score}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_progress!.correctChoices}/${_progress!.totalChoices} correct',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to stories list
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_story == null || _currentScene == null || _progress == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Story')),
        body: const Center(child: BubbleLoader()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFF6F00),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFF6F00),
                    const Color(0xFFFFA000),
                    Colors.cyan.shade600,
                  ],
                ),
              ),
            ),

            // Aquarium bubble decorations
            Positioned.fill(child: CustomPaint(painter: BubblePainter())),

            // Main content
            Column(
              children: [
                // Header with progress
                _buildHeader(),

                // Story text area
                Expanded(flex: 3, child: _buildStoryText()),

                // Choices area
                Expanded(flex: 2, child: _buildChoices()),
              ],
            ),

            // Feedback overlay
            if (_showingFeedback) _buildFeedbackOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalScenes = _story!.scenes.length;
    final visitedScenes = _progress!.visitedSceneIds.length;
    final progressValue = visitedScenes / totalScenes;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => _confirmExit(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _story!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: AppRadius.xsRadius,
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: AppOverlays.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.amber,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppOverlays.white20,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Text(
                  '$visitedScenes/$totalScenes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryText() {
    return FadeTransition(
      opacity: _textOpacity,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.largeRadius,
          boxShadow: [
            BoxShadow(
              color: AppOverlays.black20,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scene emoji/icon if available
              if (_currentScene!.imageUrl != null)
                Center(
                  child: Text(
                    _currentScene!.imageUrl!,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              if (_currentScene!.imageUrl != null) const SizedBox(height: AppSpacing.md),

              // Scene text
              Text(
                _currentScene!.text,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoices() {
    if (_currentScene!.isFinalScene) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Story'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return SlideTransition(
      position: _choiceSlideAnimation,
      child: FadeTransition(
        opacity: _textOpacity,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: _currentScene!.choices.length,
          itemBuilder: (context, index) {
            final choice = _currentScene!.choices[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChoiceButton(
                choice: choice,
                onPressed: () => _makeChoice(choice),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Positioned.fill(
      child: Container(
        color: _isCorrectChoice == true
            ? AppOverlays.green90
            : AppOverlays.orange90,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCorrectChoice == true
                      ? Icons.check_circle
                      : Icons.info_outline,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _feedbackMessage ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Story?'),
        content: const Text('Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit story
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final StoryChoice choice;
  final VoidCallback onPressed;

  const _ChoiceButton({required this.choice, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.mediumRadius,
      elevation: AppElevation.level2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: const Color(0xFFFFE082), width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  choice.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFFFFA000),
                size: AppIconSizes.sm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for floating bubbles in background
class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppOverlays.white10
      ..style = PaintingStyle.fill;

    // Draw some random bubbles
    final bubbles = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.15),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.4),
    ];

    for (final bubble in bubbles) {
      canvas.drawCircle(bubble, 30, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
