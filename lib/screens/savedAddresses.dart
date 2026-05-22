import 'package:flutter/material.dart';
import '../../models/address.dart';
import '../services/userService.dart';
import 'addressFormDialog.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final UserService _userService = UserService();

  // ✅ Состояния
  List<Address> _addresses = [];
  String? _selectedAddressId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  // ✅ Загрузка адресов из Firestore
  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final addresses = await _userService.getAddresses();
      setState(() {
        _addresses = addresses;

        // ✅ ИСПРАВЛЕНО: Используем where вместо firstWhere
        final defaultAddress = addresses.where((addr) => addr.isDefault).toList();
        _selectedAddressId = defaultAddress.isNotEmpty ? defaultAddress.first.id : null;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load addresses';
        _isLoading = false;
      });
      print('❌ Error loading addresses: $e');
    }
  }

  // ✅ Выбор адреса
  Future<void> _selectAddress(String addressId) async {
    // Снимаем isDefault со всех адресов
    for (var addr in _addresses) {
      if (addr.id != addressId && addr.isDefault) {
        await _userService.updateAddress(addr.copyWith(isDefault: false));
      }
    }

    // Устанавливаем выбранный как дефолтный
    await _userService.setDefaultAddress(addressId);

    setState(() {
      _selectedAddressId = addressId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address selected'), duration: Duration(seconds: 2)),
    );
  }

  // ✅ Удаление адреса
  Future<void> _removeAddress(String addressId, String addressName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('Are you sure you want to delete "$addressName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.removeAddress(addressId);
        _loadAddresses(); // Перезагрузить список
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete address'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ✅ Показать диалог добавления/редактирования
  Future<void> _showAddressDialog({Address? existingAddress}) async {
    final streetController = TextEditingController(text: existingAddress?.street);
    final apartmentController = TextEditingController(text: existingAddress?.apartment);
    final cityController = TextEditingController(text: existingAddress?.city ?? 'Astana');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressFormDialog(
        streetController: streetController,
        apartmentController: apartmentController,
        cityController: cityController,
        existingAddress: existingAddress,
        onSave: (address) async {
          try {
            if (existingAddress != null) {
              await _userService.updateAddress(address);
            } else {
              await _userService.addAddress(address);
            }
            _loadAddresses();
            if (mounted) Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved addresses',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadAddresses, child: const Text('Retry')),
                ],
              ),
            )
                : _addresses.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _addresses.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _buildAddressTile(address);
              },
            ),
          ),

          // Кнопка добавления
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showAddressDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB07183),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Пустой экран
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No saved addresses yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first address for faster checkout',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Элемент адреса
  Widget _buildAddressTile(Address address) {
    final isSelected = _selectedAddressId == address.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Radio<String>(
        value: address.id,
        groupValue: _selectedAddressId,
        onChanged: (value) => _selectAddress(value!),
        activeColor: const Color(0xFFB07183),
      ),
      title: Text(
        address.street,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address.apartment?.isNotEmpty == true)
            Text(address.apartment!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text('${address.city}${address.country != null ? ', ${address.country}' : ''}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (address.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB07183).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Default', style: TextStyle(fontSize: 11, color: Color(0xFFB07183), fontWeight: FontWeight.w500)),
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            onSelected: (value) {
              if (value == 'edit') {
                _showAddressDialog(existingAddress: address);
              } else if (value == 'delete') {
                _removeAddress(address.id, address.street);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}