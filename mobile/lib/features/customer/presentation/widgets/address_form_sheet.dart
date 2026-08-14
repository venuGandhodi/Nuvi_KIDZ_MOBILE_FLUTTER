import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../domain/shopify_customer.dart';

class AddressFormSheet extends StatefulWidget {
  final ShopifyAddress? initialAddress;
  final bool isEditing;
  final Future<void> Function(
    Map<String, dynamic> addressData,
    bool makeDefault,
  )
  onSave;

  const AddressFormSheet({
    super.key,
    this.initialAddress,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _zipController;

  bool _setAsDefault = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _address1Controller = TextEditingController(text: addr?.address1 ?? '');
    _address2Controller = TextEditingController(text: addr?.address2 ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _provinceController = TextEditingController(text: addr?.province ?? '');
    _zipController = TextEditingController(text: addr?.zip ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final addressData = {
      if (_firstNameController.text.trim().isNotEmpty)
        'firstName': _firstNameController.text.trim(),
      if (_lastNameController.text.trim().isNotEmpty)
        'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address1': _address1Controller.text.trim(),
      if (_address2Controller.text.trim().isNotEmpty)
        'address2': _address2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'province': _provinceController.text.trim(),
      'zip': _zipController.text.trim(),
      'country': 'India',
    };

    try {
      await widget.onSave(addressData, _setAsDefault);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NuviColors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(NuviRadii.card),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: NuviSpacing.lg,
          left: NuviSpacing.lg,
          right: NuviSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + NuviSpacing.xl,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NuviColors.border,
                      borderRadius: BorderRadius.circular(NuviRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: NuviSpacing.md),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEditing ? 'Edit Address' : 'Add New Address',
                      style: NuviTypography.textTheme.headlineMedium?.copyWith(
                        color: NuviColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.lg),

                // House / Flat / Street (Address 1)
                TextFormField(
                  controller: _address1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Flat / House No. / Building *',
                    hintText: 'e.g. Flat 402, Oakwood Heights',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter flat or house address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: NuviSpacing.md),

                // Area / Landmark (Address 2)
                TextFormField(
                  controller: _address2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Area / Street / Landmark',
                    hintText: 'e.g. Near City Park',
                  ),
                ),
                const SizedBox(height: NuviSpacing.md),

                // City & State Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City *',
                          hintText: 'e.g. Hyderabad',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'City is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: NuviSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _provinceController,
                        decoration: const InputDecoration(
                          labelText: 'State *',
                          hintText: 'e.g. Telangana',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'State is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.md),

                // PIN Code & Phone Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _zipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'PIN Code *',
                          hintText: 'e.g. 500001',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'PIN is required';
                          }
                          if (val.trim().length < 5) {
                            return 'Enter valid PIN code';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: NuviSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          hintText: 'e.g. 9876543210',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Phone is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.md),

                // Checkbox: Set as default
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Set as default delivery address',
                    style: NuviTypography.textTheme.bodyMedium,
                  ),
                  value: _setAsDefault,
                  activeColor: NuviColors.secondary,
                  onChanged: (val) =>
                      setState(() => _setAsDefault = val ?? false),
                ),
                const SizedBox(height: NuviSpacing.lg),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: NuviButton(
                        text: 'Cancel',
                        type: NuviButtonType.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: NuviSpacing.md),
                    Expanded(
                      child: NuviButton(
                        text: widget.isEditing
                            ? 'Update Address'
                            : 'Save Address',
                        type: NuviButtonType.primary,
                        isLoading: _isSubmitting,
                        onPressed: _submit,
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
