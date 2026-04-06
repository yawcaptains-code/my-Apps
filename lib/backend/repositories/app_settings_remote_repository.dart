import '../supabase_bootstrap.dart';

class AppSettingsRemoteRepository {
  static const _table = 'app_settings';

  Future<Map<String, dynamic>?> getSetting(String key) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return null;

    final row = await client
        .from(_table)
        .select('value')
        .eq('key', key)
        .maybeSingle();

    if (row == null) return null;
    return row['value'] as Map<String, dynamic>?;
  }

  Future<void> upsertSetting({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return;

    await client.from(_table).upsert({
      'key': key,
      'value': value,
    });
  }
}
