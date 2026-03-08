import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../models/smart_models.dart';
import '../smart_providers.dart';

/// Screen for identifying fish or aquatic plants via camera/gallery.
class FishIdScreen extends ConsumerStatefulWidget {
  const FishIdScreen({super.key});

  @override
  ConsumerState<FishIdScreen> createState() => _FishIdScreenState();
}

class _FishIdScreenState extends ConsumerState<FishIdScreen> {
  final _picker = ImagePicker();
  File? _selectedImage;
  IdentificationResult? _result;
  bool _loading = false;
  String? _error;

  static const _systemPrompt =
      'You are Danio AI, an expert aquarist and marine biologist with 20+ years '
      'of experience in freshwater and marine fishkeeping. You identify species '
      'from photos with high accuracy and provide practical, hobbyist-friendly '
      'care information. If you are uncertain about the species, say so and '
      'provide your best guess with a confidence note. Always prioritise the '
      'safety and welfare of the animal.';

  static const _prompt = '''
Identify the fish or aquatic plant in this image. Be specific - identify to species level where possible.

Return ONLY valid JSON with these fields (no markdown, no explanation):
{
  "common_name": "string - most widely-used common name",
  "scientific_name": "string - binomial Latin name",
  "care_level": 1-5 (1=bulletproof beginner, 5=expert only),
  "ph_min": number,
  "ph_max": number,
  "temp_min": number (°C),
  "temp_max": number (°C),
  "hardness": "string - e.g. 'Soft to moderate (2-12 dGH)'",
  "max_size_cm": number,
  "diet": "string - e.g. 'Omnivore - flakes, frozen bloodworm, blanched veg'",
  "tank_mates": ["string - 3-5 compatible species by common name"],
  "compatibility_notes": "string - temperament, schooling needs, aggression notes",
  "care_tips": ["tip1", "tip2", "tip3" - practical, actionable tips],
  "is_plant": boolean,
  "confidence": "high|medium|low"
}
''';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      if (!mounted) return;
      setState(() {
        _selectedImage = File(picked.path);
        _result = null;
        _error = null;
      });

      await _identify();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Couldn\'t grab that image. Try again?');
    }
  }

  Future<void> _identify() async {
    if (_selectedImage == null) return;

    final openai = ref.read(openAIServiceProvider);
    if (!openai.isConfigured) {
      setState(() => _error = 'AI features require an OpenAI API key.\n'
          'This feature is coming soon! Stay tuned for updates.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64 = base64Encode(bytes);

      final result = await openai.chatCompletion(
        messages: [
          ChatMessage(role: 'system', content: _systemPrompt),
          ChatMessage(
            role: 'user',
            content: [
              {'type': 'text', 'text': _prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64',
                  'detail': 'high',
                },
              },
            ],
          ),
        ],
        model: OpenAIModels.vision,
        maxTokens: 1024,
      );

      // Parse JSON from the response - handle markdown code blocks.
      var text = result.text.trim();
      if (text.startsWith('```')) {
        text = text.replaceAll(RegExp(r'^```\w*\n?'), '').replaceAll('```', '');
      }

      final json = jsonDecode(text) as Map<String, dynamic>;
      final identification = IdentificationResult.fromJson(json);

      // Record in AI history.
      ref.read(aiHistoryProvider.notifier).add(
        type: 'fish_id',
        summary: 'Identified: ${identification.commonName}',
      );

      if (!mounted) return;
      setState(() {
        _result = identification;
        _loading = false;
      });
    } on OpenAIException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'AI error: ${e.message}';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Couldn\'t identify that fish. Try a clearer photo!';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identify Fish or Plant'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview or placeholder
            _buildImageArea(theme, isDark),
            const SizedBox(height: AppSpacing.md),

            // Action buttons
            if (_selectedImage == null || _result != null) ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Loading state
            if (_loading) _buildLoading(),

            // Error state
            if (_error != null) _buildError(),

            // Result card
            if (_result != null) _buildResultCard(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea(ThemeData theme, bool isDark) {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: AppRadius.md2Radius,
        child: Image.file(
          _selectedImage!,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
        borderRadius: AppRadius.md2Radius,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Take a photo or pick from gallery\nto identify a fish or plant',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Analysing image with AI...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildError() {
    return Card(
      color: AppColors.errorAlpha10,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme, bool isDark) {
    final r = _result!;
    return Card(
      elevation: AppElevation.level1,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md2Radius,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  r.isPlant ? Icons.eco : Icons.set_meal,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.commonName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        r.scientificName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCareLevel(r.careLevel),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            // Confidence indicator
            if (r.confidence != 'high')
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14,
                        color: r.confidence == 'low' ? AppColors.warning : AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      r.confidence == 'low'
                          ? 'Low confidence - verify with another source'
                          : 'Medium confidence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: r.confidence == 'low' ? AppColors.warning : AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Key stats row
            if (r.maxSizeCm != null || r.diet != null) ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  if (r.maxSizeCm != null)
                    _paramChip('Max Size', '${r.maxSizeCm!.toStringAsFixed(0)} cm'),
                  if (r.diet != null)
                    _paramChip('Diet', r.diet!),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Water parameters
            Text(
              'Water Parameters',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _paramChip('pH', '${r.phMin}-${r.phMax}'),
                _paramChip('Temp', '${r.tempMin}-${r.tempMax}°C'),
                _paramChip('Hardness', r.hardness),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Tank mates
            if (r.tankMates.isNotEmpty) ...[
              Text(
                'Compatible Tank Mates',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: r.tankMates.map((mate) => Chip(
                  label: Text(mate, style: theme.textTheme.bodySmall),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Compatibility
            Text(
              'Compatibility Notes',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(r.compatibilityNotes, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),

            // Care tips
            Text(
              'Care Tips',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...r.careTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: Theme.of(context).textTheme.titleMedium!),
                    Expanded(
                      child: Text(tip, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Add to tank button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // Pop back with result data that can be used to pre-fill
                  // the add livestock flow.
                  Navigator.of(context).pop(r);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add to My Tank'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildCareLevel(int level) {
    return Column(
      children: [
        Text(
          'Care',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return Icon(
              Icons.star,
              size: 14,
              color: i < level ? AppColors.warning : AppColors.border,
            );
          }),
        ),
      ],
    );
  }

  Widget _paramChip(String label, String value) {
    return Chip(
      avatar: null,
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
