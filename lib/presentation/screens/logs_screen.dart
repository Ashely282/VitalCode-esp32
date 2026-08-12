import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/emotion_log.dart';
import '../providers/emotion_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/emotion_log_card.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  void _openEditSheet(BuildContext context, EmotionLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => EditLogBottomSheet(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? AppColors.accentLime : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Robot Telemetry & Intake Logs',
          style: TextStyle(color: headerColor),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Intake & Emotion Log Feed Header Title
                      Text(
                        'Intake & Emotion Log Feed',
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 20,
                          color: headerColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                Consumer<EmotionProvider>(
                  builder: (context, emotionProvider, child) {
                    final logs = emotionProvider.logs;

                    if (logs.isEmpty) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'No telemetry receipts logged yet.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final log = logs[index];
                            return EmotionLogCard(
                              log: log,
                              onTap: () => _openEditSheet(context, log),
                            );
                          },
                          childCount: logs.length,
                        ),
                      ),
                    );
                  },
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditLogBottomSheet extends StatefulWidget {
  final EmotionLog log;

  const EditLogBottomSheet({super.key, required this.log});

  @override
  State<EditLogBottomSheet> createState() => _EditLogBottomSheetState();
}

class _EditLogBottomSheetState extends State<EditLogBottomSheet> {
  late UserMood _selectedMood;
  late TextEditingController _symptomsController;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.log.mood;
    _symptomsController = TextEditingController(
      text: widget.log.symptoms ?? '',
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _saveUpdates() {
    context.read<EmotionProvider>().updateLog(
      id: widget.log.id,
      mood: _selectedMood,
      symptoms: _symptomsController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.successEmerald,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Updated log with ${_selectedMood.label} mood & symptoms.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // iOS Handle Bar
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Title
          Text(
            'Edit Log & Add Symptoms',
            style: AppTypography.displayLarge.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            'Override robot mood classification or add post-dose symptom notes.',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Section A: Edit Mood State
          Text(
            'OVERRIDE DETECTED MOOD STATE',
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: UserMood.values.map((moodOption) {
              final isSelected = moodOption == _selectedMood;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMood = moodOption),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? moodOption.color.withValues(alpha: 0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? moodOption.color
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          moodOption.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          moodOption.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Section B: Add Symptoms / Notes
          Text(
            'SYMPTOMS & NOTES',
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _symptomsController,
            maxLines: 3,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Mild headache after taking dose, resting now...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section C: Save Action Button
          CustomButton(
            label: 'Save Updates',
            icon: Icons.check_circle_rounded,
            onPressed: _saveUpdates,
          ),
        ],
      ),
    );
  }
}
