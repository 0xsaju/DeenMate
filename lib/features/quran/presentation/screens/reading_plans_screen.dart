import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/reading_plans_service.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';

class ReadingPlansScreen extends ConsumerStatefulWidget {
  const ReadingPlansScreen({super.key});

  @override
  ConsumerState<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends ConsumerState<ReadingPlansScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(readingPlansProvider);
    final statsAsync = ref.watch(readingStatsProvider);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getBackgroundColor(context),
        elevation: 0,
        title: Text(
          'Reading Plans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.getTextPrimaryColor(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeHelper.getPrimaryColor(context),
          labelColor: ThemeHelper.getPrimaryColor(context),
          unselectedLabelColor: ThemeHelper.getTextSecondaryColor(context),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'My Plans'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlansTab(plansAsync),
          _buildTodayTab(),
          _buildStatsTab(statsAsync),
        ],
      ),
      floatingActionButton: _tabController.index == 0 
        ? FloatingActionButton.extended(
            onPressed: _showCreatePlanDialog,
            icon: const Icon(Icons.add),
            label: const Text('New Plan'),
          )
        : null,
    );
  }

  Widget _buildPlansTab(AsyncValue<List<ReadingPlan>> plansAsync) {
    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return _buildEmptyPlans();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Active plan highlight
            ...plans.where((p) => p.isActive).map((plan) => 
              _buildActivePlanCard(plan)),
            
            if (plans.any((p) => p.isActive))
              const SizedBox(height: 20),
            
            // All plans
            ...plans.map((plan) => _buildPlanCard(plan)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading plans: $error'),
      ),
    );
  }

  Widget _buildActivePlanCard(ReadingPlan plan) {
    final progressAsync = ref.watch(readingProgressProvider(plan.id));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeHelper.getPrimaryColor(context),
            ThemeHelper.getPrimaryColor(context).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _getPlanTypeIcon(plan.type),
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              plan.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            progressAsync.when(
              data: (progress) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '${(progress?.completionPercentage ?? 0 * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress?.completionPercentage ?? 0,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildPlanStat('${plan.totalDays}', 'Days'),
                const SizedBox(width: 24),
                _buildPlanStat('${plan.versesPerDay}', 'Verses/Day'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _viewPlanDetails(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ThemeHelper.getPrimaryColor(context),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(ReadingPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: plan.isActive 
              ? ThemeHelper.getPrimaryColor(context).withOpacity(0.1)
              : ThemeHelper.getTextSecondaryColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getPlanTypeIcon(plan.type),
            color: plan.isActive 
              ? ThemeHelper.getPrimaryColor(context)
              : ThemeHelper.getTextSecondaryColor(context),
            size: 24,
          ),
        ),
        title: Text(
          plan.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSmallStat(Icons.calendar_today, '${plan.totalDays} days'),
                const SizedBox(width: 16),
                _buildSmallStat(Icons.menu_book, '${plan.versesPerDay} verses/day'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onPlanAction(value, plan),
          itemBuilder: (context) => [
            if (!plan.isActive)
              const PopupMenuItem(value: 'start', child: Text('Start Plan')),
            if (plan.isActive)
              const PopupMenuItem(value: 'stop', child: Text('Stop Plan')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _viewPlanDetails(plan),
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: ThemeHelper.getTextSecondaryColor(context),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTab() {
    final todaysReadingAsync = ref.watch(todaysReadingProvider);
    
    return todaysReadingAsync.when(
      data: (reading) {
        if (reading == null) {
          return _buildNoReadingToday();
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodaysReadingCard(reading),
              const SizedBox(height: 20),
              _buildReadingProgress(reading),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading today\'s reading: $error'),
      ),
    );
  }

  Widget _buildTodaysReadingCard(DailyReading reading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
            ThemeHelper.getPrimaryColor(context).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeHelper.getPrimaryColor(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DAY ${reading.dayNumber}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.schedule,
                size: 16,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(reading.estimatedReadingTime),
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeHelper.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Today\'s Reading',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          
          const SizedBox(height: 12),
          
          ...reading.verseRanges.map((range) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: ThemeHelper.getPrimaryColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    range.displayText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeHelper.getTextPrimaryColor(context),
                    ),
                  ),
                ),
                Text(
                  '${range.verseCount} verses',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startReading(reading),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Reading'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _markAsComplete(reading),
                icon: const Icon(Icons.check),
                label: const Text('Mark Complete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingProgress(DailyReading reading) {
    // TODO: Show reading progress, streak info, etc.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Text(
        'Reading progress tracking coming soon...',
        style: TextStyle(
          fontSize: 14,
          color: ThemeHelper.getTextSecondaryColor(context),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildStatsTab(AsyncValue<ReadingStats> statsAsync) {
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsOverview(stats),
            const SizedBox(height: 20),
            _buildStreakCard(stats),
            const SizedBox(height: 20),
            _buildReadingTimeCard(stats),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading stats: $error'),
      ),
    );
  }

  Widget _buildStatsOverview(ReadingStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('${stats.totalPlans}', 'Total Plans')),
              Expanded(child: _buildStatItem('${stats.completedPlans}', 'Completed')),
              Expanded(child: _buildStatItem('${stats.activePlans}', 'Active')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('${stats.totalDaysRead}', 'Days Read')),
              Expanded(child: _buildStatItem(_formatDuration(stats.totalReadingTime), 'Total Time')),
              Expanded(child: _buildStatItem(_formatDuration(stats.averageReadingTime), 'Avg Time')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.getPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStreakCard(ReadingStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading Streak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${stats.currentStreak} days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Best: ${stats.longestStreak}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingTimeCard(ReadingStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          // TODO: Add reading time chart/visualization
          Text(
            'Reading time visualization coming soon...',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlans() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No Reading Plans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a reading plan to build consistent\nQuran reading habits',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePlanDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReadingToday() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.today_outlined,
            size: 64,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No Reading Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a reading plan to get\ndaily reading recommendations',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePlanDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }

  // Helper methods

  IconData _getPlanTypeIcon(ReadingPlanType type) {
    switch (type) {
      case ReadingPlanType.thirtyDay:
        return Icons.calendar_month;
      case ReadingPlanType.ramadan:
        return Icons.nights_stay;
      case ReadingPlanType.custom:
        return Icons.tune;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  // Action handlers

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreatePlanDialog(),
    );
  }

  void _onPlanAction(String action, ReadingPlan plan) {
    switch (action) {
      case 'start':
        ref.read(readingPlansServiceProvider).startPlan(plan.id);
        break;
      case 'stop':
        ref.read(readingPlansServiceProvider).stopPlan(plan.id);
        break;
      case 'edit':
        _editPlan(plan);
        break;
      case 'delete':
        _deletePlan(plan);
        break;
    }
  }

  void _viewPlanDetails(ReadingPlan plan) {
    // TODO: Navigate to plan details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View plan details: ${plan.name}')),
    );
  }

  void _editPlan(ReadingPlan plan) {
    // TODO: Show edit plan dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit plan: ${plan.name}')),
    );
  }

  void _deletePlan(ReadingPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(readingPlansServiceProvider).deletePlan(plan.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _startReading(DailyReading reading) {
    // TODO: Navigate to reading screen with today's verses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Start reading day ${reading.dayNumber}')),
    );
  }

  void _markAsComplete(DailyReading reading) {
    // TODO: Show completion dialog with notes/time tracking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mark day ${reading.dayNumber} as complete')),
    );
  }
}

class _CreatePlanDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends ConsumerState<_CreatePlanDialog> {
  int _selectedIndex = 0;
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Reading Plan'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plan type selection
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('30-Day')),
                ButtonSegment(value: 1, label: Text('Ramadan')),
                ButtonSegment(value: 2, label: Text('Custom')),
              ],
              selected: {_selectedIndex},
              onSelectionChanged: (value) {
                setState(() {
                  _selectedIndex = value.first;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Plan name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plan Name',
                hintText: 'Enter plan name',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createPlan,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createPlan() async {
    final service = ref.read(readingPlansServiceProvider);
    final name = _nameController.text.trim();
    
    try {
      switch (_selectedIndex) {
        case 0: // 30-Day
          await service.create30DayPlan(name: name.isNotEmpty ? name : null);
          break;
        case 1: // Ramadan
          await service.createRamadanPlan(name: name.isNotEmpty ? name : null);
          break;
        case 2: // Custom
          // TODO: Show custom plan creation flow
          break;
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading plan created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating plan: $e')),
        );
      }
    }
  }
}

// Providers (to be added to main providers file)
final readingPlansServiceProvider = Provider<ReadingPlansService>((ref) {
  final quranRepo = ref.watch(quranRepoProvider);
  return ReadingPlansService(quranRepo);
});

final readingPlansProvider = StreamProvider<List<ReadingPlan>>((ref) {
  final service = ref.watch(readingPlansServiceProvider);
  return service.plansStream;
});

final readingProgressProvider = FutureProvider.family<ReadingProgress?, String>((ref, planId) async {
  final service = ref.watch(readingPlansServiceProvider);
  return service.getProgress(planId);
});

final todaysReadingProvider = FutureProvider<DailyReading?>((ref) async {
  final service = ref.watch(readingPlansServiceProvider);
  return service.getTodaysReading();
});

final readingStatsProvider = FutureProvider<ReadingStats>((ref) async {
  final service = ref.watch(readingPlansServiceProvider);
  return service.getReadingStats();
});
