import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../models/skill_model.dart';
import '../../../../widgets/comon/material_icon_mapper.dart';

class EditSkillDialog extends StatefulWidget {
  final SkillModel skill;

  const EditSkillDialog({super.key, required this.skill});

  @override
  State<EditSkillDialog> createState() => _EditSkillDialogState();
}

class _EditSkillDialogState extends State<EditSkillDialog> {
  final _formKey = GlobalKey<FormState>();

  //Controllerswith existing data
  late TextEditingController _nameController;
  late TextEditingController _orderController;

  //Form values existing data
  late String _selectedCategory;
  late int _selectedIconCode;
  late bool _isVisible;
  bool _isLoading = false;

  final List<String> _categories = [
    'Mobile Development',
    'Backend & APIs',
    'State Management',
    'Database',
    'Programming',
    'Tools & Others',
    'Web Development',
    'Cloud Services',
  ];

  final Map<String, int> _popularIcons = {
    'Phone Android': 58240,
    'Code': 57704,
    'Web': 59636,
    'Storage': 58062,
    'Cloud': 58045,
    'Settings': 59576,
    'Build': 59591,
    'API': 58835,
    'Database': 58829,
    'Laptop': 58165,
    'Devices': 57777,
    'Memory': 58313,
    'Developer Mode': 57764,
    'Terminal': 60399,
    'Language': 59500,
    'Extension': 59616,
    'Integration': 59847,
    'Lightbulb': 59568,
    'Rocket': 60120,
    'Star': 59448,
  };

  @override
  void initState() {
    super.initState();

    //Initialize with existing skill data
    _nameController = TextEditingController(text: widget.skill.name);
    _orderController = TextEditingController(
      text: widget.skill.order.toString(),
    );
    _selectedCategory = widget.skill.category;
    _selectedIconCode = widget.skill.iconCode;
    _isVisible = widget.skill.isVisible;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  // Update skill in Firebase
  Future<void> _updateSkill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated SkillModel

      final updatedSkill = SkillModel(
        id: widget.skill.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        iconCode: _selectedIconCode,
        order: int.tryParse(_orderController.text) ?? 0,
        isVisible: _isVisible,
      );

      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );

      await portfolioProvider.updateSkill(widget.skill.id, updatedSkill);

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' "${updatedSkill.name}" updated successfully! '),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error:  ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = isDark ? const Color(0xFF1E2640) : Colors.white;
    final borderColor = isDark
        ? AppTheme.primaryColor.withAlpha(76)
        : AppTheme.getBorderColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 720),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(20),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 20),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 20),
                      _buildIconPicker(),
                      const SizedBox(height: 20),
                      _buildOrderField(),
                      const SizedBox(height: 20),
                      _buildVisibilityToggle(),
                    ],
                  ),
                ),
              ),
            ),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  //Dialog Header Edit mode
  Widget _buildHeader() {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.secondaryColor.withAlpha(30)
            : AppTheme.secondaryColor.withAlpha(15),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondaryColor,
                  AppTheme.primaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryColor.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Skill',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Update skill information and display settings',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: AppTheme.getTextSecondary(context)),
          ),
        ],
      ),
    );
  }

  //Form Fields
  Widget _buildNameField() {
    final isDark = AppTheme.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Name *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Flutter, Firebase, Django',
            hintStyle: TextStyle(
              color: AppTheme.getTextHint(context),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.label_outline_rounded,
              color: AppTheme.secondaryColor,
              size: 20,
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A).withAlpha(150)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.secondaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a skill name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final isDark = AppTheme.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withAlpha(150)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppTheme.secondaryColor,
                size: 26,
              ),
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    final isDark = AppTheme.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withAlpha(150)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.secondaryColor.withAlpha(isDark ? 80 : 120),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondaryColor,
                      AppTheme.primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withAlpha(50),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MaterialIconMapper.fromCode(_selectedIconCode),
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Icon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code:  $_selectedIconCode',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),

              ElevatedButton.icon(
                onPressed: _showIconPickerDialog,
                icon: const Icon(Icons.palette_outlined, size: 16),
                label: const Text('Change'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor.withAlpha(30),
                  foregroundColor: AppTheme.secondaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderField() {
    final isDark = AppTheme.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Display Order',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Lower numbers appear first (0 = first position)',
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppTheme.getTextHint(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _orderController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.sort_rounded,
              color: AppTheme.secondaryColor,
              size: 20,
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A).withAlpha(150)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.secondaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _isVisible
            ? (isDark ? Colors.green.withAlpha(30) : const Color(0xFFECFDF5))
            : (isDark ? Colors.orange.withAlpha(30) : const Color(0xFFFFFBEB)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isVisible
              ? (isDark ? Colors.green.withAlpha(100) : const Color(0xFF86EFAC))
              : (isDark ? Colors.orange.withAlpha(100) : const Color(0xFFFCD34D)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: _isVisible ? Colors.green.shade600 : Colors.orange.shade700,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isVisible ? 'Visible on website' : 'Hidden from website',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isVisible
                      ? 'This skill will appear on your public portfolio'
                      : 'This skill will be hidden from visitors',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isVisible,
            onChanged: (value) {
              setState(() {
                _isVisible = value;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  //Footer (Update button instead of Add)
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.getBorderColor(context)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppTheme.getBorderColor(context)),
                foregroundColor: AppTheme.getTextSecondary(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateSkill,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIconPickerDialog() {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E2640) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.getBorderColor(context)),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.palette_rounded, color: AppTheme.secondaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose Icon',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppTheme.getTextSecondary(context)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: _popularIcons.length,
                  itemBuilder: (context, index) {
                    final entry = _popularIcons.entries.elementAt(index);
                    final isSelected = entry.value == _selectedIconCode;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIconCode = entry.value;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.secondaryColor.withAlpha(40)
                              : (isDark
                                  ? const Color(0xFF0F172A).withAlpha(150)
                                  : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.secondaryColor
                                : AppTheme.getBorderColor(context),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MaterialIconMapper.fromCode(entry.value),
                              color: isSelected
                                  ? AppTheme.secondaryColor
                                  : (isDark ? AppTheme.textSecondary : const Color(0xFF475569)),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.secondaryColor
                                    : AppTheme.getTextHint(context),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
