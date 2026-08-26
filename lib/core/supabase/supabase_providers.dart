import 'package:comunexa/core/supabase/comunexa_supabase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente Supabase cuando el bootstrap lo inicializó; `null` si no hay credenciales.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!ComunexaSupabase.isInitialized) return null;
  return ComunexaSupabase.client;
});
