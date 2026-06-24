import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ledger_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ledger_state_views.dart';
import '../widgets/project_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LedgerProvider>().loadLedger();
    });
  }

  Future<void> _onRefresh() {
    return context.read<LedgerProvider>().loadLedger(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<LedgerProvider>(
          builder: (context, ledger, _) {
            return RefreshIndicator(
              color: AppTheme.accent,
              backgroundColor: AppTheme.surface,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: AppHeader(lastSyncedAt: ledger.lastSyncedAt),
                  ),
                  if (ledger.state == LedgerLoadState.loading &&
                      ledger.projects.isEmpty)
                    const SliverToBoxAdapter(child: LedgerLoadingView()),
                  if (ledger.state == LedgerLoadState.error &&
                      ledger.projects.isEmpty)
                    SliverToBoxAdapter(
                      child: LedgerErrorView(
                        message: ledger.errorMessage ?? 'Unknown error',
                        onRetry: () => ledger.loadLedger(forceRefresh: true),
                      ),
                    ),
                  if (ledger.errorMessage != null &&
                      ledger.projects.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          'Partial sync warning: ${ledger.errorMessage}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFB45309),
                              ),
                        ),
                      ),
                    ),
                  if (ledger.state == LedgerLoadState.success &&
                      ledger.projects.isEmpty)
                    const SliverToBoxAdapter(child: LedgerEmptyView()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverList.separated(
                      itemCount: ledger.projects.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return ProjectCard(project: ledger.projects[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
