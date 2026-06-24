import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LedgerErrorView extends StatelessWidget {
  const LedgerErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CRITICAL LEDGER SYSTEM ERROR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB91C1C),
              side: const BorderSide(color: Color(0xFFB91C1C)),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('RETRY SYNC'),
          ),
        ],
      ),
    );
  }
}

class LedgerLoadingView extends StatelessWidget {
  const LedgerLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          2,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 220,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.border),
            ),
            child: const Center(
              child: Text(
                'Synchronizing ledger stream...',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LedgerEmptyView extends StatelessWidget {
  const LedgerEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'Ledger is empty. Run the scraper pipeline to populate data.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
      ),
    );
  }
}
