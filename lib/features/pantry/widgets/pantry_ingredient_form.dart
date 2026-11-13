import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/pantry_ingredient.dart';

class PantryIngredientForm extends StatefulWidget {
  const PantryIngredientForm({this.ingredient, super.key});

  final PantryIngredient? ingredient;

  @override
  State<PantryIngredientForm> createState() => _PantryIngredientFormState();
}

class _PantryIngredientFormState extends State<PantryIngredientForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;
  late PantryCategory _category;
  late DateTime _expiryDate;

  bool get _isEditing => widget.ingredient != null;

  @override
  void initState() {
    super.initState();
    final ingredient = widget.ingredient;
    _nameController = TextEditingController(text: ingredient?.name ?? '');
    _quantityController = TextEditingController(
      text: ingredient?.quantity.toString() ?? '',
    );
    _unitController = TextEditingController(text: ingredient?.unit ?? '');
    _noteController = TextEditingController(text: ingredient?.note ?? '');
    _category = ingredient?.category ?? PantryCategory.tea;
    _expiryDate = ingredient?.expiryDate ?? DateUtils.dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
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
                _isEditing ? 'Chỉnh sửa nguyên liệu' : 'Thêm nguyên liệu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              TextFormField(
                key: const ValueKey('pantry-name-field'),
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tên nguyên liệu',
                  hintText: 'Ví dụ: Chanh vàng',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập tên nguyên liệu'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PantryCategory>(
                key: const ValueKey('pantry-category-field'),
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: [
                  for (final category in PantryCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: const ValueKey('pantry-quantity-field'),
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                      validator: (value) {
                        final quantity = double.tryParse(
                          (value ?? '').trim().replaceAll(',', '.'),
                        );
                        if (quantity == null ||
                            !quantity.isFinite ||
                            quantity <= 0) {
                          return 'Nhập số lớn hơn 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: const ValueKey('pantry-unit-field'),
                      controller: _unitController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Đơn vị'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nhập đơn vị'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                key: const ValueKey('pantry-expiry-field'),
                borderRadius: BorderRadius.circular(18),
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Hạn sử dụng',
                    suffixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                  child: Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(_expiryDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('pantry-note-field'),
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (không bắt buộc)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('pantry-save-button'),
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm vào Pantry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: today.subtract(const Duration(days: 3650)),
      lastDate: today.add(const Duration(days: 3650)),
      helpText: 'Chọn hạn sử dụng',
    );
    if (selectedDate != null && mounted) {
      setState(() => _expiryDate = DateUtils.dateOnly(selectedDate));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existing = widget.ingredient;
    final ingredient = PantryIngredient(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _category,
      quantity: double.parse(
        _quantityController.text.trim().replaceAll(',', '.'),
      ),
      unit: _unitController.text.trim(),
      expiryDate: _expiryDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    Navigator.of(context).pop(ingredient);
  }
}
