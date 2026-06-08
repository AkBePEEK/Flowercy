import 'package:flutter/material.dart';
import '../../services/aiFloristService.dart';
import '../../services/language_service.dart';
import '../../services/orderService.dart';
import '../../services/userService.dart';
import '../../models/bouquetRequest.dart';
import '../../widgets/universal_image.dart';

class BouquetComposerScreen extends StatefulWidget {
  final List<String> initialFlowers;
  const BouquetComposerScreen({super.key, required this.initialFlowers});

  @override
  State<BouquetComposerScreen> createState() => _BouquetComposerScreenState();
}

class _BouquetComposerScreenState extends State<BouquetComposerScreen> with LanguageStateMixin {
  final AIFloristService _aiService = AIFloristService();
  bool _isLoading = true;
  Map<String, dynamic>? _structure;
  List<Map<String, dynamic>> _catalogFlowers = [];
  final List<Map<String, dynamic>> _selections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final t = getTranslations();
    setState(() => _isLoading = true);
    try {
      final flowers = await _aiService.getCatalogFlowers();
      final structure = await _aiService.get3DStructure(widget.initialFlowers);
      
      setState(() {
        _catalogFlowers = flowers;
        _structure = structure;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('error')}: $e')),
        );
      }
    }
  }

  Future<void> _finalizeComposition() async {
    final t = getTranslations();
    setState(() => _isLoading = true);
    try {
      final variations = await _aiService.composeBouquet(
        selections: _selections.map((s) => {
          'flower_id': s['flower_id'],
          'count': s['count'],
        }).toList(),
      );

      if (mounted) {
        _showVariations(variations);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('error')}: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVariations(List<Map<String, dynamic>> variations) {
    final t = getTranslations();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('proposed_variations'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: variations.length,
                  itemBuilder: (context, index) {
                    final v = variations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (v['image'] != null || v['generated_image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: UniversalImage(imagePath: v['image'] ?? v['generated_image']),
                                ),
                              ),
                            Text(
                              v['name'] ?? 'Custom Bouquet ${index + 1}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(v['description'] ?? 'Expertly composed by AI'),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${v['price']} ₸',
                                  style: const TextStyle(
                                    fontSize: 20, 
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB07183),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _sendToFlorist(v),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB07183),
                                  ),
                                  child: Text(t('send_to_florist')),
                                ),
                              ],
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

  Future<void> _sendToFlorist(Map<String, dynamic> bouquet) async {
    final t = getTranslations();
    final userService = UserService();
    final user = await userService.getCurrentUser();

    if (user == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('signIn'))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = BouquetRequest(
        id: '',
        userId: user.id,
        userName: user.name ?? user.email.split('@').first,
        userPhone: user.phone ?? '',
        bouquetName: bouquet['name'] ?? 'Custom Composer Bouquet',
        flowers: bouquet['description'] ?? 'Custom selection',
        price: bouquet['price'] ?? 0,
        createdAt: DateTime.now(),
      );

      await OrderService().createBouquetRequest(request);

      if (mounted) {
        Navigator.pop(context); // Close variations sheet
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t('request_sent')),
            content: Text('${t('request_sent_desc')} "${bouquet['name']}"'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to AI screen
                },
                child: Text(t('success')),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t('error')}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Scaffold(
      appBar: AppBar(
        title: Text(t('bouquet_composer')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_selections.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => setState(() => _selections.clear()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 3D Visualizer Placeholder
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.view_in_ar, size: 64, color: Color(0xFFB07183)),
                              const SizedBox(height: 12),
                              Text(
                                '3D Visualization (${_structure?['total_count'] ?? 0} elements)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selections.isNotEmpty)
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _selections.map((s) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB07183).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text('${s['name']} x${s['count']}', style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => setState(() => _selections.remove(s)),
                                        child: const Icon(Icons.close, size: 14, color: Color(0xFFB07183)),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Flower Selection Area
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('select_flowers'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _catalogFlowers.length,
                            itemBuilder: (context, index) {
                              final flower = _catalogFlowers[index];
                              final isSelected = _selections.any((s) => s['flower_id'] == flower['id']);
                              
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: UniversalImage(imagePath: flower['image']),
                                  ),
                                ),
                                title: Text(flower['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('${flower['price_per_stem']} ₸'),
                                trailing: isSelected
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: () {
                                              setState(() {
                                                final idx = _selections.indexWhere((s) => s['flower_id'] == flower['id']);
                                                if (_selections[idx]['count'] > 1) {
                                                  _selections[idx]['count']--;
                                                } else {
                                                  _selections.removeAt(idx);
                                                }
                                              });
                                            },
                                          ),
                                          Text('${_selections.firstWhere((s) => s['flower_id'] == flower['id'])['count']}'),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFB07183)),
                                            onPressed: () {
                                              setState(() {
                                                final idx = _selections.indexWhere((s) => s['flower_id'] == flower['id']);
                                                _selections[idx]['count']++;
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFFB07183)),
                                        onPressed: () {
                                          setState(() {
                                            _selections.add({
                                              'flower_id': flower['id'],
                                              'count': 1,
                                              'name': flower['name'],
                                            });
                                          });
                                        },
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _selections.isEmpty ? null : _finalizeComposition,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB07183),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              '${t('finalize_composition')} (${_selections.fold<int>(0, (sum, item) => sum + (item['count'] as int))})',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
