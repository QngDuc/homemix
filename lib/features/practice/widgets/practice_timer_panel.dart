import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/practice_timer_controller.dart';

class PracticeTimerPanel extends StatelessWidget {
  const PracticeTimerPanel({required this.controller, super.key});

  final PracticeTimerController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final seconds = (controller.remaining.inMilliseconds + 999) ~/ 1000;
        final formatted =
            '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
            '${(seconds % 60).toString().padLeft(2, '0')}';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_rounded, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bộ đếm thời gian',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('practice-timer-configure'),
                    onPressed: () => _configureTimer(context),
                    child: const Text('Đặt giờ'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                formatted,
                key: const ValueKey('practice-timer-value'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 38,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    key: ValueKey(
                      controller.isRunning
                          ? 'practice-timer-pause'
                          : 'practice-timer-start',
                    ),
                    onPressed: controller.isRunning
                        ? controller.pause
                        : controller.start,
                    icon: Icon(
                      controller.isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(controller.isRunning ? 'Tạm dừng' : 'Bắt đầu'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.coral,
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('practice-timer-reset'),
                    onPressed: controller.reset,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Đặt lại'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _configureTimer(BuildContext context) async {
    final seconds = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _TimerDurationSheet(initialSeconds: controller.duration.inSeconds),
    );
    if (seconds != null && context.mounted) {
      controller.setDuration(Duration(seconds: seconds));
    }
  }
}

class _TimerDurationSheet extends StatefulWidget {
  const _TimerDurationSheet({required this.initialSeconds});

  final int initialSeconds;

  @override
  State<_TimerDurationSheet> createState() => _TimerDurationSheetState();
}

class _TimerDurationSheetState extends State<_TimerDurationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _secondsController = TextEditingController(
      text: widget.initialSeconds.toString(),
    );
  }

  @override
  void dispose() {
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Đặt thời lượng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const ValueKey('practice-timer-seconds-field'),
                  controller: _secondsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Thời lượng (giây)',
                    helperText: 'Nhập từ 1 đến 7.200 giây',
                  ),
                  validator: (value) {
                    final seconds = int.tryParse(value?.trim() ?? '');
                    if (seconds == null || seconds < 1 || seconds > 7200) {
                      return 'Nhập số giây từ 1 đến 7.200';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('practice-timer-save'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.of(context)
                            .pop(int.parse(_secondsController.text.trim()));
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
