import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(SupabaseClient client) : _client = client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChangeStream => _client.auth.onAuthStateChange;

  Future<AuthResponse> login({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() {
    return _client.auth.signOut();
  }
}
