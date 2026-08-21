import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/entities/fitness_goal.dart';

class FitnessGoalDialog extends StatefulWidget {
  const FitnessGoalDialog({super.key});

  @override
  State<FitnessGoalDialog> createState() => _FitnessGoalDialogState();
}

class _FitnessGoalDialogState extends State<FitnessGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late FitnessGoalMetric _metric;
  late FitnessGoalPeriod _period;
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _metric = FitnessGoalMetric.walkingDistance;
    _period = FitnessGoalPeriod.daily;
    _targetController = TextEditingController();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(
      'Create fitness goal',
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    ),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<FitnessGoalMetric>(
              initialValue: _metric,
              decoration: const InputDecoration(
                labelText: 'Metric',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final metric in FitnessGoalMetric.values)
                  DropdownMenuItem(value: metric, child: Text(metric.label)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _metric = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FitnessGoalPeriod>(
              initialValue: _period,
              decoration: const InputDecoration(
                labelText: 'Period',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final period in FitnessGoalPeriod.values)
                  DropdownMenuItem(value: period, child: Text(period.label)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _period = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Target',
                suffixText: _metric.unit,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final target = double.tryParse(value?.trim() ?? '');
                if (target == null || !target.isFinite || target <= 0) {
                  return 'Enter a target greater than zero.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'The goal is locked after creation. You can only cancel it and '
              'create a new goal.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF616161),
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Create')),
    ],
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      FitnessGoalInput(
        metric: _metric,
        period: _period,
        targetValue: double.parse(_targetController.text.trim()),
      ),
    );
  }
}
