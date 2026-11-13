import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../../discover/widgets/drink_artwork.dart';
import '../../journal/providers/journal_providers.dart';
import '../../journal/widgets/journal_entry_form.dart';
import '../providers/practice_providers.dart';
import '../domain/practice_recipe.dart';
import '../domain/practice_session_controller.dart';
import '../domain/practice_timer_controller.dart';
import '../widgets/practice_step_illustration.dart';
import '../widgets/practice_timer_panel.dart';

class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen>
    with WidgetsBindingObserver {
  final _timer = PracticeTimerController();
  PracticeSessionController? _session;
  String? _sessionRecipeId;
  bool _journalSaved = false;
  bool _savingJournal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant PracticeSessionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeId != widget.recipeId) {
      _discardSession();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _timer.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.dispose();
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(practiceRecipeProvider(widget.recipeId));
    return recipe.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: FeatureLoadingState(message: 'Đang mở buổi thực hành...'),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: FeatureErrorState(
            message: 'Chưa thể mở công thức này.',
            onRetry: () =>
                ref.invalidate(practiceRecipeProvider(widget.recipeId)),
          ),
        ),
      ),
      data: (value) {
        if (value == null) {
          return Scaffold(
            backgroundColor: AppColors.cream,
            body: SafeArea(
              child: _NotFound(onBack: () => context.go('/practice')),
            ),
          );
        }
        final session = _sessionFor(value);
        return AnimatedBuilder(
          animation: session,
          builder: (context, child) => Scaffold(
            backgroundColor: AppColors.cream,
            body: SafeArea(
              child: session.isFinished
                  ? _buildCompletion(context, value, session)
                  : _buildSession(context, value, session),
            ),
          ),
        );
      },
    );
  }

  PracticeSessionController _sessionFor(PracticeRecipe recipe) {
    if (_sessionRecipeId != recipe.recipe.id) {
      _discardSession();
      _session = PracticeSessionController(recipe);
      _sessionRecipeId = recipe.recipe.id;
      _journalSaved = false;
      _resetTimerForStep(recipe.steps.first);
    }
    return _session!;
  }

  void _discardSession() {
    _timer.pause();
    _timer.reset();
    _session?.dispose();
    _session = null;
    _sessionRecipeId = null;
    _journalSaved = false;
    _savingJournal = false;
  }

  void _resetTimerForStep(PracticeStep step) {
    _timer.setDuration(Duration(seconds: step.suggestedSeconds ?? 30));
  }

  void _goPrevious(PracticeSessionController session) {
    session.goPrevious();
    _resetTimerForStep(session.recipe.steps[session.currentStepIndex]);
  }

  void _goNext(PracticeSessionController session) {
    session.goNext();
    _resetTimerForStep(session.recipe.steps[session.currentStepIndex]);
  }

  void _completeStep(PracticeSessionController session) {
    session.completeCurrentStep();
    _timer.pause();
    if (session.isFinished) {
      _timer.reset();
    }
  }

  Widget _buildSession(
    BuildContext context,
    PracticeRecipe practice,
    PracticeSessionController session,
  ) {
    final recipe = practice.recipe;
    final step = practice.steps[session.currentStepIndex];

    return CustomScrollView(
      key: const ValueKey('practice-session-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PracticeBackButton(
                      onPressed: () => context.go('/practice'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: DrinkArtwork(style: recipe.artwork),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      recipe.description,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.muted, height: 1.45),
                    ),
                    const SizedBox(height: 13),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.hourglass_bottom_rounded,
                          label: 'Chuẩn bị ${practice.preparationMinutes} phút',
                        ),
                        _InfoPill(
                          icon: Icons.schedule_rounded,
                          label: 'Pha ${practice.mixingMinutes} phút',
                        ),
                      ],
                    ),
                    const SizedBox(height: 21),
                    _ServingsControl(
                      servings: session.servings,
                      onChanged: session.setServings,
                    ),
                    const SizedBox(height: 13),
                    _IngredientsCard(
                      practice: practice,
                      servings: session.servings,
                    ),
                    const SizedBox(height: 11),
                    _ToolsCard(tools: practice.tools),
                    const SizedBox(height: 23),
                    _StepProgress(session: session),
                    const SizedBox(height: 12),
                    PracticeStepIllustration(
                      visual: step.visual,
                      stepNumber: session.currentStepIndex + 1,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      step.instruction,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(height: 1.55),
                    ),
                    if (step.suggestedSeconds != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Thời gian gợi ý: ${_formatDuration(step.suggestedSeconds!)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    PracticeTimerPanel(controller: _timer),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('practice-complete-step'),
                        onPressed: session.currentStepIsComplete
                            ? null
                            : () => _completeStep(session),
                        icon: Icon(
                          session.currentStepIsComplete
                              ? Icons.check_circle_rounded
                              : Icons.check_rounded,
                        ),
                        label: Text(
                          session.currentStepIsComplete
                              ? 'Đã hoàn thành bước'
                              : 'Hoàn thành bước',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('practice-previous-step'),
                            onPressed: session.currentStepIndex == 0
                                ? null
                                : () => _goPrevious(session),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Quay lại'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            key: const ValueKey('practice-next-step'),
                            onPressed: session.canGoNext
                                ? () => _goNext(session)
                                : null,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Bước tiếp'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletion(
    BuildContext context,
    PracticeRecipe practice,
    PracticeSessionController session,
  ) {
    final recipe = practice.recipe;
    return CustomScrollView(
      key: const ValueKey('practice-completion-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 190,
                      child: DrinkArtwork(style: recipe.artwork),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration_rounded,
                            color: AppColors.coral,
                            size: 44,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bạn đã hoàn thành!',
                            key: const ValueKey('practice-completion-title'),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontSize: 25),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recipe.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${session.completedStepCount}/${practice.steps.length} bước đã hoàn thành',
                            key: const ValueKey('practice-completion-count'),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 19),
                          Text(
                            'Bạn thấy thành phẩm thế nào?',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              for (var value = 1; value <= 5; value++)
                                IconButton(
                                  key: ValueKey('practice-rating-$value'),
                                  tooltip: '$value sao',
                                  onPressed: _journalSaved
                                      ? null
                                      : () => session.setRating(value),
                                  icon: Icon(
                                    value <= (session.rating ?? 0)
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: AppColors.orange,
                                    size: 30,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    FilledButton.icon(
                      key: const ValueKey('practice-save-journal'),
                      onPressed: _journalSaved || _savingJournal
                          ? null
                          : () => _saveToJournal(session),
                      icon: Icon(
                        _journalSaved
                            ? Icons.bookmark_added_rounded
                            : Icons.bookmark_add_rounded,
                      ),
                      label: Text(
                        _journalSaved
                            ? 'Đã lưu vào Journal'
                            : 'Lưu kết quả vào Journal',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 9),
                    OutlinedButton.icon(
                      key: const ValueKey('practice-restart'),
                      onPressed: _restartPractice,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Thực hành lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    if (!_journalSaved) ...[
                      const SizedBox(height: 5),
                      TextButton(
                        key: const ValueKey('practice-skip-journal'),
                        onPressed: () => context.go('/practice'),
                        child: const Text('Bỏ qua, không lưu nhật ký'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveToJournal(PracticeSessionController session) async {
    final draft = await showJournalEntryForm(
      context,
      initialRating: session.rating,
    );
    if (draft == null || !mounted) {
      return;
    }

    final result = session.createResult();
    setState(() => _savingJournal = true);
    try {
      await ref
          .read(journalEntriesProvider.notifier)
          .addEntry(
            recipeId: result.recipeId,
            recipeName: result.recipeName,
            date: result.completedAt,
            rating: draft.rating,
            note: draft.note,
          );
      if (mounted) {
        setState(() => _journalSaved = true);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Đã lưu kết quả vào Journal.')),
          );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Không thể lưu vào Journal: $error')),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _savingJournal = false);
      }
    }
  }

  void _restartPractice() {
    final session = _session;
    if (session == null) {
      return;
    }
    session.restart();
    _journalSaved = false;
    _resetTimerForStep(session.recipe.steps.first);
  }
}

class _PracticeBackButton extends StatelessWidget {
  const _PracticeBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    key: const ValueKey('practice-session-back'),
    onPressed: onPressed,
    style: IconButton.styleFrom(backgroundColor: AppColors.white),
    icon: const Icon(Icons.arrow_back_rounded),
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.coral),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ServingsControl extends StatelessWidget {
  const _ServingsControl({required this.servings, required this.onChanged});

  final int servings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_drink_outlined, color: AppColors.coral),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Khẩu phần',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            key: const ValueKey('practice-serving-decrease'),
            onPressed: servings > 1 ? () => onChanged(servings - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColors.coral,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '$servings',
            key: const ValueKey('practice-serving-count'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            key: const ValueKey('practice-serving-increase'),
            onPressed: servings < 12 ? () => onChanged(servings + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.coral,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  const _IngredientsCard({required this.practice, required this.servings});

  final PracticeRecipe practice;
  final int servings;

  @override
  Widget build(BuildContext context) {
    final recipe = practice.recipe;
    return _DetailCard(
      title: 'Nguyên liệu',
      icon: Icons.eco_rounded,
      child: Column(
        children: [
          for (var index = 0; index < recipe.ingredients.length; index++) ...[
            if (index > 0) const Divider(height: 17),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipe.ingredients[index].name,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.navy),
                  ),
                ),
                Text(
                  practice.amountFor(recipe.ingredients[index], servings),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolsCard extends StatelessWidget {
  const _ToolsCard({required this.tools});

  final List<String> tools;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Dụng cụ cần chuẩn bị',
      icon: Icons.kitchen_rounded,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final tool in tools)
            Chip(
              visualDensity: VisualDensity.compact,
              backgroundColor: AppColors.cream,
              side: const BorderSide(color: AppColors.border),
              label: Text(tool),
            ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.coral, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.session});

  final PracticeSessionController session;

  @override
  Widget build(BuildContext context) {
    final current = session.currentStepIndex + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bước $current/${session.recipe.steps.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${session.completedStepCount} bước xong',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            key: const ValueKey('practice-progress'),
            value: session.progress,
            minHeight: 8,
            color: AppColors.coral,
            backgroundColor: AppColors.border,
          ),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _PracticeBackButton(onPressed: onBack),
        ),
        const Expanded(
          child: FeatureEmptyState(
            title: 'Không tìm thấy công thức',
            message: 'Công thức này có thể đã được cập nhật.',
          ),
        ),
      ],
    );
  }
}

String _formatDuration(int seconds) {
  if (seconds < 60) {
    return '$seconds giây';
  }
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return remainingSeconds == 0
      ? '$minutes phút'
      : '$minutes phút $remainingSeconds giây';
}
