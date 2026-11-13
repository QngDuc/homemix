import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/journal_entry.dart';

Future<JournalEntryDraft?> showJournalEntryForm(
  BuildContext context, {
  int? initialRating,
  String initialNote = '',
  String title = 'Lưu vào Journal',
  String saveLabel = 'Lưu nhật ký',
}) {
  return showModalBottomSheet<JournalEntryDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => JournalEntryForm(
      initialRating: initialRating,
      initialNote: initialNote,
      title: title,
      saveLabel: saveLabel,
    ),
  );
}

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({
    required this.initialRating,
    required this.initialNote,
    required this.title,
    required this.saveLabel,
    super.key,
  });

  final int? initialRating;
  final String initialNote;
  final String title;
  final String saveLabel;

  @override
  State<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<JournalEntryForm> {
  late final TextEditingController _noteController;
  int? _rating;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _noteController.dispose();
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
          child: SingleChildScrollView(
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
                const SizedBox(height: 17),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ghi lại cảm nhận để lần sau pha được đúng gu hơn.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 15),
                Text(
                  'Đánh giá thành phẩm (tuỳ chọn)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    for (var value = 1; value <= 5; value++)
                      IconButton(
                        key: ValueKey('journal-form-rating-$value'),
                        tooltip: '$value sao',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _rating = value),
                        icon: Icon(
                          value <= (_rating ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.orange,
                          size: 29,
                        ),
                      ),
                    if (_rating != null)
                      TextButton(
                        onPressed: () => setState(() => _rating = null),
                        child: const Text('Bỏ đánh giá'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('journal-form-note'),
                  controller: _noteController,
                  maxLines: 4,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú cá nhân',
                    hintText: 'Hương vị, điều bạn muốn thay đổi lần sau...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('journal-form-cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('journal-form-save'),
                        onPressed: () => Navigator.of(context).pop(
                          JournalEntryDraft(
                            rating: _rating,
                            note: _noteController.text.trim(),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(widget.saveLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
