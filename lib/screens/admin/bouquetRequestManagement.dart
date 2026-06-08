import 'package:flutter/material.dart';
import '../../models/bouquetRequest.dart';
import '../../services/language_service.dart';
import '../../services/orderService.dart';
import '../../widgets/universal_image.dart';

class BouquetRequestManagementScreen extends StatefulWidget {
  const BouquetRequestManagementScreen({super.key});

  @override
  State<BouquetRequestManagementScreen> createState() => _BouquetRequestManagementScreenState();
}

class _BouquetRequestManagementScreenState extends State<BouquetRequestManagementScreen> with LanguageStateMixin {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('bouquet_requests'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BouquetRequest>>(
        stream: _orderService.getAllBouquetRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return Center(child: Text(t('no_requests_yet')));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildRequestAdminCard(requests[index], t),
          );
        },
      ),
    );
  }

  Widget _buildRequestAdminCard(BouquetRequest request, AppTranslations t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (request.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: UniversalImage(imagePath: request.image),
                  ),
                ),
              if (request.image != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          request.bouquetName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        _buildRequestStatusBadge(request.status, t),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${t('recipient')}: ${request.userName}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (request.userPhone.isNotEmpty) Text('📞 ${request.userPhone}'),
          Text('💐 ${request.flowers}'),
          Text('💰 ${request.price} ₸'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (request.status == 'pending') ...[
                TextButton(
                  onPressed: () => _orderService.updateRequestStatus(request.id, 'cancelled'),
                  child: Text(t('cancel'), style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _orderService.updateRequestStatus(request.id, 'accepted'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: Text(t('accept')),
                ),
              ],
              if (request.status == 'accepted')
                ElevatedButton(
                  onPressed: () => _orderService.updateRequestStatus(request.id, 'completed'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: Text(t('complete')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestStatusBadge(String status, AppTranslations t) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'accepted': color = Colors.green; break;
      case 'completed': color = Colors.blue; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        t('request_status_${status.toLowerCase()}'),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
