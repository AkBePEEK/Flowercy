// ✅ Диалог добавления/редактирования адреса
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/address.dart';

class AddressFormDialog extends StatefulWidget {
  final TextEditingController streetController;
  final TextEditingController apartmentController;
  final TextEditingController cityController;
  final Address? existingAddress;
  final Function(Address) onSave;

  const AddressFormDialog({
    required this.streetController,
    required this.apartmentController,
    required this.cityController,
    this.existingAddress,
    required this.onSave,
  });

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _isDefault = widget.existingAddress?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingAddress != null ? 'Edit address' : 'Add new address',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),

            // Street
            const Text('Street address *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.streetController,
              decoration: InputDecoration(
                hintText: 'e.g., Uly Dala Avenue, 31',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) => value?.isEmpty == true ? 'Street is required' : null,
            ),
            const SizedBox(height: 16),

            // Apartment
            const Text('Apartment / Office / Floor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.apartmentController,
              decoration: InputDecoration(
                hintText: 'e.g., Apt. 510, 5th floor',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // City
            const Text('City *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.cityController,
              decoration: InputDecoration(
                hintText: 'e.g., Astana',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) => value?.isEmpty == true ? 'City is required' : null,
            ),
            const SizedBox(height: 24),

            // Default checkbox
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value ?? false),
              title: const Text('Set as default address', style: TextStyle(fontSize: 14)),
              activeColor: const Color(0xFFB07183),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final address = Address(
                      id: widget.existingAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      street: widget.streetController.text.trim(),
                      apartment: widget.apartmentController.text.trim().isEmpty ? null : widget.apartmentController.text.trim(),
                      city: widget.cityController.text.trim(),
                      isDefault: _isDefault,
                    );
                    widget.onSave(address);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB07183),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.existingAddress != null ? 'Save changes' : 'Add address',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}