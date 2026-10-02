import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../models/skill_model.dart';
import '../../../../widgets/comon/material_icon_mapper.dart';

class AddSkillDialog extends StatefulWidget {
  const AddSkillDialog({super.key});

  @override
  State<AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  //Form key for validation
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _orderController = TextEditingController(text: '0');

  //Form values
  String _selectedCategory = 'Mobile Development';
  int _selectedIconCode = 58240; // Default icon
  bool _isVisible = true;
  bool _isLoading = false;

  //Predefined categories
  // Admin can select  or type new category
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

  // commonly used icons for Icon picker
  final Map<String, int> _popularIcons = {
    'Phone Android': 58240, // phone_android
    'Code': 57704, // code
    'Web': 59636, // web
    'Storage': 58062, // storage
    'Cloud': 58045, // cloud
    'Settings': 59576, // settings
    'Build': 59591, // build
    'API': 58835, // api
    'Database': 58829, // database
    'Laptop': 58165, // laptop
    'Devices': 57777, // devices
    'Memory': 58313, // memory
    'Developer Mode': 57764, // developer_mode
    'Terminal': 60399, // terminal
    'Language': 59500, // language
    'Extension': 59616, // extension
    'Integration': 59847, // integration_instructions
    'Lightbulb': 59568, // lightbulb
    'Rocket': 60120, // rocket_launch
    'Star': 59448, // star
  };

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  //Save skill to Firebase
  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      //SkillModel object
      final newSkill = SkillModel(
        id: '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        iconCode: _selectedIconCode,
        order: int.tryParse(_orderController.text) ?? 0,
        isVisible: _isVisible,
      );

      //Save newSkill to Firebase Using Provider
      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );

      await portfolioProvider.addSkill(newSkill);

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' "${newSkill.name}" added successfully! '),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      //Error handling
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
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
            // Header
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Skill Name
                      _buildNameField(),

                      const SizedBox(height: 20),

                      // Category Dropdown
                      _buildCategoryDropdown(),

                      const SizedBox(height: 20),

                      // Icon Picker
                      _buildIconPicker(),

                      const SizedBox(height: 20),

                      // Display Order
                      _buildOrderField(),

                      const SizedBox(height: 20),

                      // Visibility Toggle
                      _buildVisibilityToggle(),
                    ],
                  ),
                ),
              ),
            ),

            //Footer Actions
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Dialog Header
  Widget _buildHeader() {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryColor.withAlpha(30)
            : AppTheme.primaryColor.withAlpha(15),
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
              gradient: AppTheme.getPrimaryGradient(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Skill',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Configure skill title, category, and display order',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: AppTheme.getTextSecondary(context)),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  //Skill Name Field
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
              color: AppTheme.primaryColor,
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
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
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
            if (value.trim().length < 2) {
              return 'Skill name must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Category Dropdown
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
                color: AppTheme.primaryColor,
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

  //Icon Picker
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

        /// Selected icon preview
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withAlpha(150)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withAlpha(isDark ? 80 : 120),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(50),
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
                      'Code: $_selectedIconCode',
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
                  backgroundColor: AppTheme.primaryColor.withAlpha(30),
                  foregroundColor: AppTheme.primaryColor,
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

  // Display Order Field
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
            hintText: '0',
            hintStyle: TextStyle(color: AppTheme.getTextHint(context)),
            prefixIcon: Icon(
              Icons.sort_rounded,
              color: AppTheme.primaryColor,
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
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Visibility Toggle
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

  //Footer with Action Buttons
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
          /// Cancel Button
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

          /// Save Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSkill,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.primaryColor,
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
                      'Add Skill',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  //Show Icon Picker Dialog
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  Icon(Icons.palette_rounded, color: AppTheme.primaryColor),
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

              /// Icon Grid
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
                              ? AppTheme.primaryColor.withAlpha(40)
                              : (isDark
                                  ? const Color(0xFF0F172A).withAlpha(150)
                                  : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
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
                                  ? AppTheme.primaryColor
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
                                    ? AppTheme.primaryColor
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
