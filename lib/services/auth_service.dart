import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this.client);

  final SupabaseClient client;

  User? get currentUser => client.auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signUpParent({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim(), 'phone': phone.trim()},
    );

    final user = response.user;
    if (user != null && response.session != null) {
      await client.from('guardians').upsert({
        'user_id': user.id,
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
      }, onConflict: 'user_id');
    }
  }

  Future<String?> currentRole() async {
    final user = currentUser;
    if (user == null) return null;
    final row = await client
        .from('profiles')
        .select('role')
        .eq('user_id', user.id)
        .maybeSingle();
    return row?['role'] as String?;
  }

  Future<void> signOut() => client.auth.signOut();
}
