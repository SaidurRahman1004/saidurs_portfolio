import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../models/skill_model.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient.scale(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Skill',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add a new skill to your portfolio',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  //Skill Name Field
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Name *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g., Flutter, Firebase, Django',
            prefixIcon: const Icon(Icons.label_outline),
            filled: true,
            fillColor: AppTheme.darkBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.darkBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceColor.withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  //Icon Picker
  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        /// Selected icon preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient.scale(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  IconData(_selectedIconCode, fontFamily: 'MaterialIcons'),
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Icon',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'Code: $_selectedIconCode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: _showIconPickerDialog,
                child: const Text('Change'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Display Order Field
  Widget _buildOrderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Display Order',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Lower numbers appear first (0 = first position)',
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _orderController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: const Icon(Icons.sort),
            filled: true,
            fillColor: AppTheme.darkBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isVisible
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isVisible
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isVisible ? Icons.visibility : Icons.visibility_off,
            color: _isVisible ? Colors.green : Colors.orange,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isVisible ? 'Visible on website' : 'Hidden from website',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  _isVisible
                      ? 'This skill will appear on your public portfolio'
                      : 'This skill will be hidden from visitors',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.surfaceColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          /// Cancel Button
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppTheme.textSecondary),
              ),
              child: const Text('Cancel'),
            ),
          ),

          const SizedBox(width: 16),

          /// Save Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSkill,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
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
                  : const Text('Add Skill'),
            ),
          ),
        ],
      ),
    );
  }

  //Show Icon Picker Dialog
  void _showIconPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  Icon(Icons.palette, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose Icon',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : AppTheme.darkBackground.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconData(
                                entry.value,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondary,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.textHint,
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
