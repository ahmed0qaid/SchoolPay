import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const SchoolPayApp());

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
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    const Icon(Icons.account_balance_wallet_rounded, size: 76),
                    const SizedBox(height: 16),
                    Text(
                      'SchoolPay',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'إدارة الرسوم والأقساط وسندات القبض للمدرسة',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminHome()),
                      ),
                      icon: const Icon(Icons.school_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('دخول إدارة المدرسة'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ParentHome()),
                      ),
                      icon: const Icon(Icons.family_restroom_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('دخول ولي الأمر'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'نسخة MVP تجريبية — سيتم ربط الحسابات بقاعدة البيانات في المرحلة التالية.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
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

class Student {
  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.guardian,
    required this.phone,
    required this.totalFees,
    required this.installments,
    required this.payments,
  });

  final String id;
  final String name;
  final String grade;
  final String guardian;
  final String phone;
  final double totalFees;
  final List<Installment> installments;
  final List<Payment> payments;

  double get paid => payments.fold(0, (sum, item) => sum + item.amount);
  double get remaining => totalFees - paid;
}

class Installment {
  const Installment({
    required this.label,
    required this.dueDate,
    required this.amount,
    required this.paid,
  });

  final String label;
  final DateTime dueDate;
  final double amount;
  final double paid;

  double get remaining => amount - paid;
  String get status {
    if (paid >= amount) return 'مدفوع';
    if (paid > 0) return 'جزئي';
    if (DateTime.now().isAfter(dueDate)) return 'متأخر';
    return 'قادم';
  }
}

class Payment {
  const Payment({
    required this.receiptNo,
    required this.date,
    required this.amount,
    required this.method,
  });

  final String receiptNo;
  final DateTime date;
  final double amount;
  final String method;
}

final demoStudents = <Student>[
  Student(
    id: 'ST-1001',
    name: 'أحمد محمد علي',
    grade: 'الصف السادس',
    guardian: 'محمد علي',
    phone: '777123456',
    totalFees: 120000,
    installments: [
      Installment(label: 'سبتمبر', dueDate: DateTime(2026, 9, 1), amount: 30000, paid: 30000),
      Installment(label: 'أكتوبر', dueDate: DateTime(2026, 10, 1), amount: 30000, paid: 20000),
      Installment(label: 'نوفمبر', dueDate: DateTime(2026, 11, 1), amount: 30000, paid: 20000),
      Installment(label: 'ديسمبر', dueDate: DateTime(2026, 12, 1), amount: 30000, paid: 0),
    ],
    payments: [
      Payment(receiptNo: 'REC-2026-0001', date: DateTime(2026, 9, 1), amount: 30000, method: 'نقدي'),
      Payment(receiptNo: 'REC-2026-0002', date: DateTime(2026, 9, 20), amount: 20000, method: 'نقدي'),
      Payment(receiptNo: 'REC-2026-0003', date: DateTime(2026, 10, 10), amount: 20000, method: 'تحويل'),
    ],
  ),
  Student(
    id: 'ST-1002',
    name: 'سارة عبدالله حسن',
    grade: 'الصف الرابع',
    guardian: 'عبدالله حسن',
    phone: '733555222',
    totalFees: 90000,
    installments: [
      Installment(label: 'سبتمبر', dueDate: DateTime(2026, 9, 1), amount: 30000, paid: 30000),
      Installment(label: 'نوفمبر', dueDate: DateTime(2026, 11, 1), amount: 30000, paid: 0),
      Installment(label: 'يناير', dueDate: DateTime(2027, 1, 1), amount: 30000, paid: 0),
    ],
    payments: [
      Payment(receiptNo: 'REC-2026-0004', date: DateTime(2026, 9, 2), amount: 30000, method: 'نقدي'),
    ],
  ),
];

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const titles = ['الرئيسية', 'الطلاب', 'الدفعات', 'المزيد'];
    final screens = [
      const DashboardView(),
      const StudentsView(),
      const PaymentsView(),
      const MoreView(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[index]),
          actions: [
            IconButton(
              tooltip: 'تسجيل الخروج',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: screens[index],
        floatingActionButton: index == 1
            ? FloatingActionButton.extended(
                onPressed: () => _showComingSoon(context, 'إضافة طالب جديد'),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('إضافة طالب'),
              )
            : index == 2
                ? FloatingActionButton.extended(
                    onPressed: () => _showComingSoon(context, 'تسجيل دفعة جديدة'),
                    icon: const Icon(Icons.add_card_rounded),
                    label: const Text('تسجيل دفعة'),
                  )
                : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'الطلاب'),
            NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'الدفعات'),
            NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: 'المزيد'),
          ],
        ),
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final total = demoStudents.fold<double>(0, (s, e) => s + e.totalFees);
    final paid = demoStudents.fold<double>(0, (s, e) => s + e.paid);
    final remaining = total - paid;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('نظرة عامة', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SummaryCard(title: 'إجمالي الرسوم', value: money(total), icon: Icons.account_balance_rounded),
            SummaryCard(title: 'تم تحصيله', value: money(paid), icon: Icons.check_circle_rounded),
            SummaryCard(title: 'المتبقي', value: money(remaining), icon: Icons.schedule_rounded),
            SummaryCard(title: 'عدد الطلاب', value: '${demoStudents.length}', icon: Icons.groups_rounded),
          ],
        ),
        const SizedBox(height: 24),
        Text('آخر الدفعات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...demoStudents.expand(
          (student) => student.payments.take(2).map(
                (payment) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.receipt_long_rounded)),
                    title: Text(student.name),
                    subtitle: Text('${payment.receiptNo} • ${payment.method}'),
                    trailing: Text(money(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: demoStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final student = demoStudents[i];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${student.grade}\nولي الأمر: ${student.guardian}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudentDetails(student: student)),
            ),
          ),
        );
      },
    );
  }
}

class StudentDetails extends StatelessWidget {
  const StudentDetails({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(student.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(student.grade, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(student.id),
                      ],
                    ),
                    const Divider(height: 28),
                    AmountRow(label: 'إجمالي الرسوم', amount: student.totalFees),
                    AmountRow(label: 'المدفوع', amount: student.paid),
                    AmountRow(label: 'المتبقي', amount: student.remaining),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('الأقساط', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...student.installments.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.label),
                  subtitle: Text('الاستحقاق: ${DateFormat('yyyy/MM/dd').format(item.dueDate)}\n${money(item.amount)}'),
                  isThreeLine: true,
                  trailing: Chip(label: Text(item.status)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('سندات القبض', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...student.payments.map(
              (payment) => Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_rounded),
                  title: Text(payment.receiptNo),
                  subtitle: Text('${DateFormat('yyyy/MM/dd').format(payment.date)} • ${payment.method}'),
                  trailing: Text(money(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReceiptScreen(student: student, payment: payment)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AmountRow extends StatelessWidget {
  const AmountRow({super.key, required this.label, required this.amount});
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(money(amount), style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <({Student student, Payment payment})>[];
    for (final student in demoStudents) {
      for (final payment in student.payments) {
        rows.add((student: student, payment: payment));
      }
    }
    rows.sort((a, b) => b.payment.date.compareTo(a.payment.date));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final row = rows[i];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.payments_rounded)),
            title: Text(row.student.name),
            subtitle: Text('${row.payment.receiptNo} • ${DateFormat('yyyy/MM/dd').format(row.payment.date)}'),
            trailing: Text(money(row.payment.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReceiptScreen(student: row.student, payment: row.payment)),
            ),
          ),
        );
      },
    );
  }
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.student, required this.payment});

  final Student student;
  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سند قبض')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.verified_rounded, size: 58),
                      const SizedBox(height: 8),
                      const Text('سند قبض رسوم مدرسية', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 18),
                      Text(payment.receiptNo, textAlign: TextAlign.center),
                      const Divider(height: 34),
                      ReceiptRow(label: 'اسم الطالب', value: student.name),
                      ReceiptRow(label: 'رقم الطالب', value: student.id),
                      ReceiptRow(label: 'ولي الأمر', value: student.guardian),
                      ReceiptRow(label: 'تاريخ الدفع', value: DateFormat('yyyy/MM/dd').format(payment.date)),
                      ReceiptRow(label: 'طريقة الدفع', value: payment.method),
                      ReceiptRow(label: 'المبلغ المستلم', value: money(payment.amount)),
                      ReceiptRow(label: 'الرصيد المتبقي', value: money(student.remaining)),
                      const Divider(height: 34),
                      const Text('هذا السند تجريبي. في النسخة المرتبطة بقاعدة البيانات سيكون السند غير قابل للحذف، وإنما يمكن إلغاؤه مع الاحتفاظ بالسجل.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptRow extends StatelessWidget {
  const ReceiptRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tile(context, Icons.calendar_month_rounded, 'خطط الأقساط'),
        _tile(context, Icons.warning_amber_rounded, 'المتأخرات'),
        _tile(context, Icons.analytics_rounded, 'التقارير'),
        _tile(context, Icons.manage_accounts_rounded, 'أولياء الأمور'),
        _tile(context, Icons.settings_rounded, 'إعدادات المدرسة'),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_left_rounded),
          onTap: () => _showComingSoon(context, title),
        ),
      );
}

class ParentHome extends StatelessWidget {
  const ParentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final student = demoStudents.first;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حساب ولي الأمر'),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('مرحبًا محمد علي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 4),
            const Text('يمكنك متابعة رسوم أبنائك وسندات الدفع من هنا.'),
            const SizedBox(height: 18),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetails(student: student))),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Text(student.grade),
                      const Divider(height: 28),
                      AmountRow(label: 'إجمالي الرسوم', amount: student.totalFees),
                      AmountRow(label: 'المدفوع', amount: student.paid),
                      AmountRow(label: 'المتبقي', amount: student.remaining),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Text('عرض التفاصيل'), SizedBox(width: 4), Icon(Icons.arrow_back_rounded, size: 18)],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String money(double value) => '${NumberFormat('#,##0').format(value)} ر.ي';

void _showComingSoon(BuildContext context, String title) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('الواجهة موجودة ضمن خطة MVP وسيتم ربطها بقاعدة البيانات في المرحلة التالية.'),
            const SizedBox(height: 18),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا')),
          ],
        ),
      ),
    ),
  );
}
