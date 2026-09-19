import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/skill_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';

class MobileSkillFormSheet extends StatefulWidget {
  final SkillModel? skill;

  const MobileSkillFormSheet({super.key, this.skill});

  static Future<void> show(BuildContext context, {SkillModel? skill}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileSkillFormSheet(skill: skill),
    );
  }

  @override
  State<MobileSkillFormSheet> createState() => _MobileSkillFormSheetState();
}

class _MobileSkillFormSheetState extends State<MobileSkillFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _orderController;
  late String _category;
  late int _iconCode;
  late bool _isVisible;
  bool _isSaving = false;

  final List<String> _categories = [
    'Mobile',
    'Frontend',
    'Backend',
    'Database',
    'DevOps & Cloud',
    'Tools & Other',
  ];

  final List<Map<String, dynamic>> _commonIcons = const [
    {'name': 'Code', 'icon': Icons.code, 'code': 57704},
    {'name': 'Android', 'icon': Icons.phone_android, 'code': 58240},
    {'name': 'Web', 'icon': Icons.web, 'code': 59636},
    {'name': 'Storage', 'icon': Icons.storage, 'code': 58062},
    {'name': 'Cloud', 'icon': Icons.cloud, 'code': 58045},
    {'name': 'Build', 'icon': Icons.build, 'code': 59591},
    {'name': 'API', 'icon': Icons.api, 'code': 58835},
    {'name': 'Settings', 'icon': Icons.settings, 'code': 59576},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.skill;
    _nameController = TextEditingController(text: s?.name ?? '');
    _orderController = TextEditingController(text: (s?.order ?? 0).toString());
    _category = s?.category ?? 'Mobile';
    _iconCode = s?.iconCode ?? Icons.code.codePoint;
    _isVisible = s?.isVisible ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final order = int.tryParse(_orderController.text.trim()) ?? 0;

      final skillData = SkillModel(
        id: widget.skill?.id ?? '',
        name: name,
        category: _category,
        iconCode: _iconCode,
        order: order,
        isVisible: _isVisible,
        createdAt: widget.skill?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.skill == null) {
        await FirebaseService.instance.addSkill(skillData);
      } else {
        await FirebaseService.instance.updateSkill(widget.skill!.id, skillData);
      }

      if (mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadAllSkills();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.skill == null ? 'Skill created!' : 'Skill updated!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save skill: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.skill != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Skill' : 'Add New Skill',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Skill Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Skill Name *',
                  hintText: 'e.g. Flutter, Kotlin, Firebase',
                  prefixIcon: const Icon(Icons.code_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : _categories.first,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Icon Selector
              Text(
                'Select Icon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonIcons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final item = _commonIcons[i];
                    final code = item['code'] as int;
                    final isSelected = _iconCode == code;

                    return InkWell(
                      onTap: () => setState(() => _iconCode = code),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.15)
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Order
              TextFormField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sort Order',
                  prefixIcon: const Icon(Icons.sort_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),

              // Visibility Switch
              SwitchListTile(
                title: const Text('Visible in Portfolio'),
                value: _isVisible,
                activeColor: const Color(0xFF10B981),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isVisible = v),
              ),
              const SizedBox(height: 18),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSkill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Add Skill',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
