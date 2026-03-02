import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/app/constants/app_constants.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/controllers/list_controller.dart';
import 'package:smart_do/services/cache_service.dart';
import 'package:smart_do/services/connectivity_service.dart';
import 'package:smart_do/widgets/error_widgets.dart';
import 'package:smart_do/widgets/loading_widgets.dart';

class DashboardScreen extends GetView<ListController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes listes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () => Get.toNamed(AppRoutes.calendar),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Get.toNamed(AppRoutes.stats),
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une liste...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        final isConnected = Get.find<ConnectivityService>().isConnected.value;

        return Column(
          children: [
            // Bannière hors ligne
            if (!isConnected) const OfflineBanner(),

            // Indicateur d'âge du cache (si connecté mais données en cache)
            if (isConnected && controller.lists.isNotEmpty)
              _buildCacheAgeBanner(),

            // Contenu principal
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshListsWithOffline,
                child: _buildBody(),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createList),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle liste'),
      ),
    );
  }

  Widget _buildCacheAgeBanner() {
    // Récupérer l'âge du cache
    final cacheAge = Get.find<CacheService>().getCacheAge(
      AppConstants.listsCacheKey,
    );

    if (cacheAge == null) return const SizedBox();

    return CacheInfoBanner(
      cacheAgeMinutes: cacheAge,
      onRefresh: controller.refreshListsWithOffline,
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: controller.refreshLists,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listes actives
            _buildSectionHeader(
              title: 'Actives',
              icon: Icons.playlist_play_rounded,
              count: controller.activeLists.length,
            ),
            _buildListsSection(controller.activeLists),

            // Listes complétées
            _buildSectionHeader(
              title: 'Terminées',
              icon: Icons.playlist_add_check_rounded,
              count: controller.completedLists.length,
            ),
            _buildListsSection(controller.completedLists),

            // Listes partagées avec moi
            _buildSectionHeader(
              title: 'Partagées avec moi',
              icon: Icons.people_rounded,
              count: controller.sharedLists.length,
            ),
            _buildSharedListsSection(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(count.toString(), style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildListsSection(RxList lists) {
    if (controller.isLoading.value && lists.isEmpty) {
      return const ShimmerList();
    }

    if (lists.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucune liste'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return _buildListCard(list);
      },
    );
  }

  Widget _buildSharedListsSection() {
    if (controller.isLoading.value && controller.sharedLists.isEmpty) {
      return const ShimmerList();
    }

    if (controller.sharedLists.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucune liste partagée'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.sharedLists.length,
      itemBuilder: (context, index) {
        final list = controller.sharedLists[index];
        return _buildSharedListCard(list);
      },
    );
  }

  Widget _buildListCard(list) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () =>
            Get.toNamed(AppRoutes.listDetailWithId(list.id), arguments: list),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Icône selon le type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: list.type == 'checklist'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      list.type == 'checklist'
                          ? Icons.checklist_rounded
                          : Icons.list_alt_rounded,
                      color: list.type == 'checklist'
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Titre et date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              list.formattedDueDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Progression
                  if (list.type == 'checklist')
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                  value: list.progress,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                              Text(
                                '${(list.progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharedListCard(list) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.blue[50],
      child: InkWell(
        onTap: () =>
            Get.toNamed(AppRoutes.listDetailWithId(list.id), arguments: list),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.people_rounded, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Partagé par ${list.ownerName ?? 'Inconnu'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      list.permission == 'edit' ? 'Édition' : 'Lecture',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
