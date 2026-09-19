import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/professional_experience_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';

class MobileExperienceFormSheet extends StatefulWidget {
  final ProfessionalExperienceModel? experience;

  const MobileExperienceFormSheet({super.key, this.experience});

  static Future<void> show(BuildContext context, {ProfessionalExperienceModel? experience}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileExperienceFormSheet(experience: experience),
    );
  }

  @override
  State<MobileExperienceFormSheet> createState() => _MobileExperienceFormSheetState();
}

class _MobileExperienceFormSheetState extends State<MobileExperienceFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _companyUrlController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _orderController;
  final TextEditingController _skillInputController = TextEditingController();

  late String _employmentType;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isCurrentRole;
  late bool _isVisible;
  late List<String> _skills;
  bool _isSaving = false;

  final List<String> _employmentTypes = ['Full-time', 'Part-time', 'Contract', 'Freelance', 'Internship'];

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    _titleController = TextEditingController(text: exp?.title ?? '');
    _companyController = TextEditingController(text: exp?.company ?? '');
    _companyUrlController = TextEditingController(text: exp?.companyUrl ?? '');
    _locationController = TextEditingController(text: exp?.location ?? 'Dhaka, Bangladesh');
    _descriptionController = TextEditingController(text: exp?.description ?? '');
    _orderController = TextEditingController(text: (exp?.order ?? 0).toString());

    _employmentType = exp?.employmentType ?? 'Full-time';
    _startDate = exp?.startDate ?? DateTime.now().subtract(const Duration(days: 365));
    _endDate = exp?.endDate;
    _isCurrentRole = exp?.isCurrentRole ?? (exp?.endDate == null);
    _isVisible = exp?.isVisible ?? true;
    _skills = List<String>.from(exp?.skills ?? ['Flutter', 'Dart']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _companyUrlController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initial = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2010),
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

  void _addSkillTag() {
    final val = _skillInputController.text.trim();
    if (val.isNotEmpty && !_skills.contains(val)) {
      setState(() {
        _skills.add(val);
        _skillInputController.clear();
      });
    }
  }

  Future<void> _saveExperience() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final expData = ProfessionalExperienceModel(
        id: widget.experience?.id ?? '',
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        companyUrl: _companyUrlController.text.trim().isNotEmpty ? _companyUrlController.text.trim() : null,
        location: _locationController.text.trim(),
        employmentType: _employmentType,
        startDate: _startDate,
        endDate: _isCurrentRole ? null : _endDate,
        isCurrentRole: _isCurrentRole,
        description: _descriptionController.text.trim(),
        responsibilities: widget.experience?.responsibilities ?? [],
        skills: _skills,
        promotions: widget.experience?.promotions ?? [],
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        isVisible: _isVisible,
        createdAt: widget.experience?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.experience == null) {
        await FirebaseService.instance.addExperience(expData);
      } else {
        await FirebaseService.instance.updateExperience(widget.experience!.id, expData);
      }

      if (mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadExperiences(includeHidden: true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.experience == null ? 'Experience added!' : 'Experience updated!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save experience: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.experience != null;
    final df = DateFormat('MMM yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
                    isEditing ? 'Edit Experience' : 'Add Experience',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Job Title / Role *',
                        hintText: 'e.g. Senior Flutter Developer',
                        prefixIcon: const Icon(Icons.work_outline_rounded),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        labelText: 'Company Name *',
                        prefixIcon: const Icon(Icons.business_rounded),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Company is required' : null,
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _employmentTypes.contains(_employmentType) ? _employmentType : _employmentTypes.first,
                      decoration: InputDecoration(
                        labelText: 'Employment Type',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _employmentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _employmentType = v!),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date Pickers Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Date',
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
                            onTap: _isCurrentRole ? null : () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                prefixIcon: const Icon(Icons.event_available_rounded, size: 18),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(_isCurrentRole ? 'Present' : (_endDate != null ? df.format(_endDate!) : 'Present')),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text('Currently working here'),
                      value: _isCurrentRole,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _isCurrentRole = v),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief summary of key achievements and roles',
                        prefixIcon: const Icon(Icons.description_outlined),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Skills Tags
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skillInputController,
                            decoration: InputDecoration(
                              labelText: 'Skills used (e.g. Flutter, BLoC)',
                              prefixIcon: const Icon(Icons.star_outline_rounded),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onFieldSubmitted: (_) => _addSkillTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addSkillTag,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: _skills.map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _skills.remove(s)),
                      )).toList(),
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
                        onPressed: _isSaving ? null : _saveExperience,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isEditing ? 'Save Changes' : 'Add Experience', style: const TextStyle(fontWeight: FontWeight.bold)),
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
