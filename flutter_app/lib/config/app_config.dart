/// Central configuration — no backend; ledger is read from GitHub Raw CDN.
abstract final class AppConfig {
  static const String ledgerUrl =
      'https://raw.githubusercontent.com/veerendrasoni07/The-Truth/main/scraper/data/ledger.json';

  static const String appTitle = 'The Public Memory Project';
  static const String appSubtitle =
      'An immutable ledger tracking long-term public timelines, metrics, and outcomes.';

  static const Duration httpTimeout = Duration(seconds: 30);
}
