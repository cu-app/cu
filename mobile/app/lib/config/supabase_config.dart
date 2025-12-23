/// Supabase Configuration
///
/// Centralized Supabase connection settings.
/// Uses environment variables from build-time defines.

import 'app_config.dart';

class SupabaseConfig {
  /// Supabase project URL
  static String get url => AppConfig.supabaseUrl;

  /// Supabase anonymous key (safe for client-side)
  static String get anonKey => AppConfig.supabaseAnonKey;

  // Table names
  static const String payeesTable = 'payees';
  static const String scheduledPaymentsTable = 'scheduled_payments';
  static const String transactionsTable = 'transactions';
  static const String accountsTable = 'accounts';
  static const String chatMessagesTable = 'chat_messages';
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
}
