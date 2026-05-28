import 'package:flutter/material.dart';
import '../../services/aiFloristService.dart';

class BouquetComposerScreen extends StatefulWidget {
  final List<String> initialFlowers;
  const BouquetComposerScreen({super.key, required this.initialFlowers});

  @override
  State<BouquetComposerScreen> createState() => _BouquetComposerScreenState();
}

class _BouquetComposerScreenState extends State<BouquetComposerScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading composer: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bouquet Composer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 3D Visualizer Placeholder
                Expanded(
                  flex: 2,
                  child: Container(
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
                ),

                // Flower Selection Area
                Expanded(
                  flex: 3,
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
                        const Text(
                          'Add Flowers to your bouquet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _catalogFlowers.length,
                            itemBuilder: (context, index) {
                              final flower = _catalogFlowers[index];
                              return ListTile(
                                title: Text(flower['name']),
                                subtitle: Text('${flower['price_per_stem']} ₸ / stem'),
                                trailing: IconButton(
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
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _selections.isEmpty ? null : () {
                              // Logic to save or proceed
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB07183),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Finalize Composition (${_selections.length})'),
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
