import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/education_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';

class MobileEducationFormSheet extends StatefulWidget {
  final EducationModel? education;

  const MobileEducationFormSheet({super.key, this.education});

  static Future<void> show(BuildContext context, {EducationModel? education}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileEducationFormSheet(education: education),
    );
  }

  @override
  State<MobileEducationFormSheet> createState() => _MobileEducationFormSheetState();
}

class _MobileEducationFormSheetState extends State<MobileEducationFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _degreeController;
  late TextEditingController _fieldController;
  late TextEditingController _institutionController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _orderController;

  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isCurrent;
  late bool _isVisible;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final edu = widget.education;
    _degreeController = TextEditingController(text: edu?.degree ?? '');
    _fieldController = TextEditingController(text: edu?.field ?? '');
    _institutionController = TextEditingController(text: edu?.institution ?? '');
    _locationController = TextEditingController(text: edu?.location ?? 'Dhaka, Bangladesh');
    _descriptionController = TextEditingController(text: edu?.description ?? '');
    _orderController = TextEditingController(text: (edu?.order ?? 0).toString());

    _startDate = edu?.startDate ?? DateTime.now().subtract(const Duration(days: 365 * 4));
    _endDate = edu?.endDate;
    _isCurrent = edu?.isCurrent ?? false;
    _isVisible = edu?.isVisible ?? true;
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _fieldController.dispose();
    _institutionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initial = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveEducation() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final eduData = EducationModel(
        id: widget.education?.id ?? '',
        degree: _degreeController.text.trim(),
        field: _fieldController.text.trim(),
        institution: _institutionController.text.trim(),
        location: _locationController.text.trim(),
        startDate: _startDate,
        endDate: _isCurrent ? null : _endDate,
        isCurrent: _isCurrent,
        description: _descriptionController.text.trim(),
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        isVisible: _isVisible,
        createdAt: widget.education?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.education == null) {
        await FirebaseService.instance.addEducation(eduData);
      } else {
        await FirebaseService.instance.updateEducation(widget.education!.id, eduData);
      }

      if (mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadEducation(includeHidden: true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.education == null ? 'Education added!' : 'Education updated!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.education != null;
    final df = DateFormat('yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Education' : 'Add Education',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _degreeController,
                      decoration: InputDecoration(
                        labelText: 'Degree / Certificate *',
                        hintText: 'e.g. B.Sc. in Computer Science',
                        prefixIcon: const Icon(Icons.school_outlined),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _fieldController,
                      decoration: InputDecoration(
                        labelText: 'Field of Study',
                        hintText: 'e.g. Software Engineering',
                        prefixIcon: const Icon(Icons.menu_book_rounded),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _institutionController,
                      decoration: InputDecoration(
                        labelText: 'Institution / University *',
                        prefixIcon: const Icon(Icons.account_balance_outlined),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Year',
                                prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(df.format(_startDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _isCurrent ? null : () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Year',
                                prefixIcon: const Icon(Icons.event_available_rounded, size: 18),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(_isCurrent ? 'Present' : (_endDate != null ? df.format(_endDate!) : 'Present')),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text('Currently Studying'),
                      value: _isCurrent,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _isCurrent = v),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description / Honors',
                        prefixIcon: const Icon(Icons.notes_rounded),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    SwitchListTile(
                      title: const Text('Visible on Resume'),
                      value: _isVisible,
                      activeColor: const Color(0xFF10B981),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _isVisible = v),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveEducation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isEditing ? 'Save Changes' : 'Add Education', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
