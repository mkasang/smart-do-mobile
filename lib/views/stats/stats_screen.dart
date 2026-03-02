import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/controllers/stats_controller.dart';
import 'package:smart_do/widgets/loading_widgets.dart';

class StatsScreen extends GetView<StatsController> {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshStats,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.value == null) {
          return const ShimmerList();
        }

        if (controller.stats.value == null) {
          return const Center(child: Text('Aucune donnée'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cartes de résumé
                _buildSummaryCards(),
                const SizedBox(height: 24),

                // Statistiques des listes
                _buildSectionTitle('Listes'),
                const SizedBox(height: 8),
                _buildListsStats(),
                const SizedBox(height: 24),

                // Statistiques des items
                _buildSectionTitle('Items'),
                const SizedBox(height: 8),
                _buildItemsStats(),
                const SizedBox(height: 24),

                // Statistiques de partage
                _buildSectionTitle('Partages'),
                const SizedBox(height: 8),
                _buildSharingStats(),
                const SizedBox(height: 24),

                // Timeline mensuelle
                _buildSectionTitle('Activité mensuelle'),
                const SizedBox(height: 8),
                _buildMonthlyTimeline(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Listes',
          value: controller.totalLists.toString(),
          icon: Icons.list_alt_rounded,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Items',
          value: controller.totalItems.toString(),
          icon: Icons.checklist_rounded,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Complétés',
          value: controller.completedItems.toString(),
          icon: Icons.task_alt_rounded,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Taux',
          value: controller.completionRateFormatted,
          icon: Icons.percent_rounded,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListsStats() {
    final lists = controller.listsStats;
    if (lists == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total', lists.total.toString()),
            const Divider(),
            _buildStatRow('Actives', lists.active.toString()),
            _buildStatRow('Terminées', lists.completed.toString()),
            const Divider(),
            _buildStatRow('Checklists', lists.checklist.toString()),
            _buildStatRow('Simples', lists.simple.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsStats() {
    final items = controller.itemsStats;
    if (items == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total', items.total.toString()),
            const Divider(),
            _buildStatRow('Complétés', items.completed.toString()),
            _buildStatRow('En attente', items.pending.toString()),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Taux de complétion'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: items.completionRate >= 50
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.completionRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: items.completionRate >= 50
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingStats() {
    final sharing = controller.sharingStats;
    if (sharing == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              'Listes partagées par moi',
              sharing.listsSharedByMe.toString(),
            ),
            _buildStatRow(
              'Partages envoyés',
              sharing.totalSharesSent.toString(),
            ),
            const Divider(),
            _buildStatRow(
              'Listes reçues',
              sharing.listsSharedWithMe.toString(),
            ),
            _buildStatRow(
              'Listes que je peux modifier',
              sharing.listsICanEdit.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTimeline() {
    if (controller.timelineStats == null) return const SizedBox();

    final monthly = controller.timelineStats!.monthly;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: monthly.take(6).map((stat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      stat.month,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${stat.listsCount} listes'),
                        const SizedBox(height: 2),
                        LinearProgressIndicator(
                          value: stat.completedCount / stat.listsCount,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            stat.completedCount == stat.listsCount
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${stat.completedCount}/${stat.listsCount}'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
