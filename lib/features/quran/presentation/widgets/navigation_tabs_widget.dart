import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/providers.dart';
import '../../data/dto/juz_dto.dart';
import '../../../../core/theme/theme_helper.dart';

/// Navigation widget with tabs for Juz, Page, Hizb, and Ruku navigation
class NavigationTabsWidget extends ConsumerWidget {
  const NavigationTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: ThemeHelper.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: ThemeHelper.getBackgroundColor(context),
          elevation: 0,
          title: Text(
            'Quran Navigation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ThemeHelper.getTextPrimaryColor(context)),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/quran');
              }
            },
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Juz', icon: Icon(Icons.bookmark_outline)),
              Tab(text: 'Page', icon: Icon(Icons.auto_stories)),
              Tab(text: 'Hizb', icon: Icon(Icons.segment)),
              Tab(text: 'Ruku', icon: Icon(Icons.format_list_numbered)),
            ],
            labelColor: ThemeHelper.getPrimaryColor(context),
            unselectedLabelColor: ThemeHelper.getTextSecondaryColor(context),
            indicatorColor: ThemeHelper.getPrimaryColor(context),
          ),
        ),
        body: const TabBarView(
          children: [
            _JuzTabView(),
            _PageTabView(),
            _HizbTabView(),
            _RukuTabView(),
          ],
        ),
      ),
    );
  }
}

/// Juz (Para) navigation tab
class _JuzTabView extends ConsumerWidget {
  const _JuzTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzListAsync = ref.watch(juzListProvider);

    return juzListAsync.when(
      data: (juzList) => _JuzListView(juzList: juzList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Error loading Juz list: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(juzListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _JuzListView extends StatelessWidget {
  const _JuzListView({required this.juzList});

  final List<JuzDto> juzList;

  @override
  Widget build(BuildContext context) {
    // If API data is not available, create static Juz list
    final displayList = juzList.isNotEmpty ? juzList : _createStaticJuzList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final juz = displayList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ThemeHelper.getPrimaryColor(context),
              child: Text(
                '${juz.juzNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Juz ${juz.juzNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Para ${juz.juzNumber} of the Quran'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to Juz reader
              context.go('/quran/juz/${juz.juzNumber}');
            },
          ),
        );
      },
    );
  }

  List<JuzDto> _createStaticJuzList() {
    return List.generate(30, (index) {
      final juzNumber = index + 1;
      return JuzDto(
        id: juzNumber,
        juzNumber: juzNumber,
        verseMapping: {},
      );
    });
  }
}

/// Page navigation tab
class _PageTabView extends StatelessWidget {
  const _PageTabView();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: 604, // Total pages in Quran
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        return Card(
          child: InkWell(
            onTap: () {
              context.go('/quran/page/$pageNumber');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '$pageNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Page',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Hizb navigation tab
class _HizbTabView extends StatelessWidget {
  const _HizbTabView();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.3,
      ),
      itemCount: 60, // Total Hizbs in Quran (30 Juz × 2 Hizbs each)
      itemBuilder: (context, index) {
        final hizbNumber = index + 1;
        final juzNumber = ((hizbNumber - 1) ~/ 2) + 1;
        final hizbInJuz = ((hizbNumber - 1) % 2) + 1;

        return Card(
          child: InkWell(
            onTap: () {
              context.go('/quran/hizb/$hizbNumber');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.segment,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '$hizbNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Hizb $hizbInJuz',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Juz $juzNumber',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Ruku navigation tab
class _RukuTabView extends StatelessWidget {
  const _RukuTabView();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.1,
      ),
      itemCount: 556, // Approximate total Rukus in Quran
      itemBuilder: (context, index) {
        final rukuNumber = index + 1;
        return Card(
          child: InkWell(
            onTap: () {
              context.go('/quran/ruku/$rukuNumber');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.format_list_numbered,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  '$rukuNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Ruku',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
