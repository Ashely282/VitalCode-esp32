import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_picker_card.dart';
import '../widgets/time_picker_card.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;

  late ValueNotifier<DateTime> _startDateNotifier;
  late ValueNotifier<DateTime> _endDateNotifier;
  late ValueNotifier<DateTime> _expirationDateNotifier;
  late ValueNotifier<TimeOfDay> _scheduleTimeNotifier;

  final _dateFormatter = DateFormat('MMM dd, yyyy');

  bool get isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    final med = widget.medicine;
    _nameController = TextEditingController(text: med?.name ?? '');
    _dosageController = TextEditingController(
      text: med?.dosage ?? '',
    );
    _instructionsController = TextEditingController(
      text: med?.instructions ?? '',
    );

    _startDateNotifier = ValueNotifier(med?.startDate ?? DateTime.now());
    _endDateNotifier = ValueNotifier(med?.endDate ?? DateTime.now().add(const Duration(days: 30)));
    _expirationDateNotifier =
        ValueNotifier(med?.expirationDate ?? DateTime.now().add(const Duration(days: 365)));

    if (med != null && med.scheduleTime.isNotEmpty) {
      _scheduleTimeNotifier = ValueNotifier(_parseTimeOfDay(med.scheduleTime));
    } else {
      _scheduleTimeNotifier = ValueNotifier(const TimeOfDay(hour: 9, minute: 0));
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final format = DateFormat.jm();
      final dt = format.parse(timeStr);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      try {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].split(' ')[0]);
        return TimeOfDay(hour: hour, minute: minute);
      } catch (_) {
        return const TimeOfDay(hour: 9, minute: 0);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _expirationDateNotifier.dispose();
    _scheduleTimeNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required BuildContext context,
    required ValueNotifier<DateTime> notifier,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: notifier.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      notifier.value = picked;
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduleTimeNotifier.value,
    );
    if (picked != null) {
      _scheduleTimeNotifier.value = picked;
    }
  }

  void _saveMedicine() {
    if (!_formKey.currentState!.validate()) return;

    final formattedTime = _scheduleTimeNotifier.value.format(context);
    final now = DateTime.now();

    var effectiveStartDate = _startDateNotifier.value;
    final scheduledToday = DateTime(
      now.year,
      now.month,
      now.day,
      _scheduleTimeNotifier.value.hour,
      _scheduleTimeNotifier.value.minute,
    );

    if (scheduledToday.isBefore(now) &&
        (_startDateNotifier.value.isBefore(now) ||
            (_startDateNotifier.value.year == now.year &&
                _startDateNotifier.value.month == now.month &&
                _startDateNotifier.value.day == now.day))) {
      effectiveStartDate = now.add(const Duration(days: 1));
    }

    if (isEditing) {
      context.read<MedicineProvider>().updateMedicine(
        id: widget.medicine!.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        startDate: effectiveStartDate,
        endDate: _endDateNotifier.value,
        expirationDate: _expirationDateNotifier.value,
        scheduleTime: formattedTime,
        instructions: _instructionsController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Updated ${_nameController.text.trim()} in companion schedule!',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      context.read<MedicineProvider>().addMedicine(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        startDate: effectiveStartDate,
        endDate: _endDateNotifier.value,
        expirationDate: _expirationDateNotifier.value,
        scheduleTime: formattedTime,
        instructions: _instructionsController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Added ${_nameController.text.trim()} to companion schedule!',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    context.pop();
  }

  void _confirmDeleteMedicine(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Medicine',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this medicine? This action cannot be undone.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondaryDark),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vitalRed,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (widget.medicine != null) {
                  final medName = widget.medicine!.name;
                  context.read<MedicineProvider>().deleteMedicine(
                    widget.medicine!.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      content: Row(
                        children: [
                          const Icon(
                            Icons.delete_forever_rounded,
                            color: AppColors.vitalRed,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Deleted $medName from schedule.',
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
                  context.pop();
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add New Medicine'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Medication Details' : 'Medication Details',
                      style: AppTypography.displayLarge.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing
                          ? 'Update medicine schedule, dosage, and timing information.'
                          : 'Enter medicine information to sync with robot camera and intake logs.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'MEDICINE NAME',
                      hint: 'e.g. Aspirin Cardio',
                      controller: _nameController,
                      prefixIcon: Icons.medication_rounded,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Medicine name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'DOSAGE & STRENGTH',
                      hint: 'e.g. 500 mg (1 Tablet)',
                      controller: _dosageController,
                      prefixIcon: Icons.scale_rounded,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Dosage is required' : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SCHEDULE & DOSAGE TIME',
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<TimeOfDay>(
                      valueListenable: _scheduleTimeNotifier,
                      builder: (context, timeValue, child) {
                        return TimePickerCard(
                          timeText: timeValue.format(context),
                          onTap: () => _pickTime(context),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<DateTime>(
                            valueListenable: _startDateNotifier,
                            builder: (context, dateValue, child) {
                              return DatePickerCard(
                                label: 'START DATE',
                                dateText: _dateFormatter.format(dateValue),
                                onTap: () => _pickDate(
                                  context: context,
                                  notifier: _startDateNotifier,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ValueListenableBuilder<DateTime>(
                            valueListenable: _endDateNotifier,
                            builder: (context, dateValue, child) {
                              return DatePickerCard(
                                label: 'END DATE',
                                dateText: _dateFormatter.format(dateValue),
                                onTap: () => _pickDate(
                                  context: context,
                                  notifier: _endDateNotifier,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _expirationDateNotifier,
                      builder: (context, dateValue, child) {
                        return DatePickerCard(
                          label: 'MEDICINE EXPIRATION DATE',
                          dateText: _dateFormatter.format(dateValue),
                          icon: Icons.event_busy_rounded,
                          onTap: () => _pickDate(
                            context: context,
                            notifier: _expirationDateNotifier,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'SPECIAL INSTRUCTIONS / NOTES',
                      hint: 'e.g. Take with food, do not crush tablet...',
                      controller: _instructionsController,
                      prefixIcon: Icons.notes_rounded,
                    ),
                    const SizedBox(height: 32),
                    ScaleTap(
                      child: CustomButton(
                        label: isEditing
                            ? 'Update Medicine Schedule'
                            : 'Save Medicine Schedule',
                        icon: isEditing
                            ? Icons.check_circle_rounded
                            : Icons.save_rounded,
                        onPressed: _saveMedicine,
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      ScaleTap(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            label: const Text(
                              'Delete Medicine',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => _confirmDeleteMedicine(context),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
