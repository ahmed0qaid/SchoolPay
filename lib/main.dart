import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'services/auth_service.dart';
import 'services/school_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey,
  );
  runApp(const SchoolPayApp());
}

class SchoolPayApp extends StatelessWidget {
  const SchoolPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SchoolPay',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF176B87),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        return session == null ? const LoginScreen() : const RoleRouter();
      },
    );
  }
}

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService(Supabase.instance.client);
    return FutureBuilder<String?>(
      future: auth.currentRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return ErrorScreen(message: snapshot.error.toString());
        }
        return snapshot.data == 'admin' ? const AdminHome() : const ParentHome();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await AuthService(Supabase.instance.client)
          .signIn(email: email.text, password: password.text);
    } on AuthException catch (e) {
      if (mounted) _message(e.message);
    } catch (_) {
      if (mounted) _message('تعذر تسجيل الدخول. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 72),
                    const SizedBox(height: 12),
                    Text('SchoolPay', textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('نظام الرسوم والسندات المدرسية', textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: loading ? null : login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('تسجيل الدخول'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentSignUpScreen())),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('إنشاء حساب ولي أمر'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParentSignUpScreen extends StatefulWidget {
  const ParentSignUpScreen({super.key});

  @override
  State<ParentSignUpScreen> createState() => _ParentSignUpScreenState();
}

class _ParentSignUpScreenState extends State<ParentSignUpScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    if (name.text.trim().isEmpty || phone.text.trim().isEmpty || email.text.trim().isEmpty || password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل البيانات، وكلمة المرور 6 أحرف على الأقل.')));
      return;
    }
    setState(() => loading = true);
    try {
      await AuthService(Supabase.instance.client).signUpParent(
        email: email.text,
        password: password.text,
        fullName: name.text,
        phone: phone.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الحساب. قد تحتاج لتأكيد البريد الإلكتروني.')));
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء حساب ولي أمر')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder())),
            const SizedBox(height: 18),
            FilledButton(onPressed: loading ? null : submit, child: Padding(padding: const EdgeInsets.all(14), child: Text(loading ? 'جاري الإنشاء...' : 'إنشاء الحساب'))),
          ],
        ),
      ),
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late final SchoolRepository repo = SchoolRepository(Supabase.instance.client);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة المدرسة'),
          actions: [IconButton(onPressed: () => AuthService(Supabase.instance.client).signOut(), icon: const Icon(Icons.logout))],
        ),
        body: FutureBuilder<List<Object>>(
          future: Future.wait([repo.totals(), repo.students()]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
            final totals = snapshot.data![0] as Map<String, num>;
            final students = snapshot.data![1] as List<Map<String, dynamic>>;
            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _StatCard('إجمالي الرسوم', totals['fees'] ?? 0),
                    _StatCard('المحصّل', totals['paid'] ?? 0),
                    _StatCard('المتبقي', totals['remaining'] ?? 0),
                  ]),
                  const SizedBox(height: 22),
                  Text('الطلاب', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (students.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('لا يوجد طلاب بعد.'))),
                  ...students.map((s) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(s['full_name'] as String),
                      subtitle: Text('${s['grade']} • ${s['student_no']}'),
                      trailing: Text(_money((s['total_fees'] as num?) ?? 0)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetails(student: s))),
                    ),
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ParentHome extends StatelessWidget {
  const ParentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SchoolRepository(Supabase.instance.client);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حساب ولي الأمر'),
          actions: [IconButton(onPressed: () => AuthService(Supabase.instance.client).signOut(), icon: const Icon(Icons.logout))],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: repo.students(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
            final students = snapshot.data!;
            if (students.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(28), child: Text('لم يتم ربط أي طالب بهذا الحساب بعد. تواصل مع إدارة المدرسة.')));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: students.map((s) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.school)),
                  title: Text(s['full_name'] as String),
                  subtitle: Text('${s['grade']} • الرسوم ${_money((s['total_fees'] as num?) ?? 0)}'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetails(student: s))),
                ),
              )).toList(),
            );
          },
        ),
      ),
    );
  }
}

class StudentDetails extends StatelessWidget {
  const StudentDetails({super.key, required this.student});
  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final repo = SchoolRepository(Supabase.instance.client);
    final id = student['id'] as String;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(student['full_name'] as String)),
        body: FutureBuilder<List<Object>>(
          future: Future.wait([repo.installmentsForStudent(id), repo.paymentsForStudent(id)]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final installments = snapshot.data![0] as List<Map<String, dynamic>>;
            final payments = snapshot.data![1] as List<Map<String, dynamic>>;
            final paid = payments.fold<num>(0, (sum, p) => sum + ((p['amount'] as num?) ?? 0));
            final total = (student['total_fees'] as num?) ?? 0;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                  _AmountRow('إجمالي الرسوم', total),
                  _AmountRow('المدفوع', paid),
                  _AmountRow('المتبقي', total - paid),
                ]))),
                const SizedBox(height: 18),
                const Text('الأقساط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (installments.isEmpty) const Text('لم يتم إنشاء خطة أقساط بعد.'),
                ...installments.map((i) => Card(child: ListTile(
                  title: Text(i['label'] as String),
                  subtitle: Text('الاستحقاق: ${i['due_date']}'),
                  trailing: Text(_money((i['amount'] as num?) ?? 0)),
                ))),
                const SizedBox(height: 18),
                const Text('الدفعات والسندات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (payments.isEmpty) const Text('لا توجد دفعات مسجلة.'),
                ...payments.map((p) {
                  final receipts = p['receipts'];
                  String receipt = 'بدون سند';
                  if (receipts is List && receipts.isNotEmpty) receipt = '${receipts.first['receipt_no']}';
                  if (receipts is Map && receipts['receipt_no'] != null) receipt = '${receipts['receipt_no']}';
                  return Card(child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(_money((p['amount'] as num?) ?? 0)),
                    subtitle: Text('$receipt • ${p['method']}'),
                  ));
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value);
  final String label;
  final num value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 175,
    child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 8),
      Text(_money(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
    ]))),
  );
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(this.label, this.amount);
  final String label;
  final num amount;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(_money(amount), style: const TextStyle(fontWeight: FontWeight.bold))]),
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(message))));
}

String _money(num value) => '${NumberFormat('#,##0.##').format(value)} ر.ي';
