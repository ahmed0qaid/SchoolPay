import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolRepository {
  SchoolRepository(this.client);
  final SupabaseClient client;

  Future<List<Map<String, dynamic>>> students() async {
    final data = await client
        .from('students')
        .select('id, student_no, full_name, grade, section, total_fees, guardian_id')
        .eq('is_active', true)
        .order('full_name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> paymentsForStudent(String studentId) async {
    final data = await client
        .from('payments')
        .select('id, amount, method, paid_at, reference, receipts(receipt_no,status)')
        .eq('student_id', studentId)
        .order('paid_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> installmentsForStudent(String studentId) async {
    final plans = await client.from('fee_plans').select('id').eq('student_id', studentId);
    if (plans.isEmpty) return [];
    final ids = plans.map((e) => e['id'] as String).toList();
    final data = await client
        .from('installments')
        .select('id,label,due_date,amount,sort_order')
        .inFilter('fee_plan_id', ids)
        .order('sort_order');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, num>> totals() async {
    final studentsData = await students();
    final totalFees = studentsData.fold<num>(0, (sum, row) => sum + ((row['total_fees'] as num?) ?? 0));
    final payments = await client.from('payments').select('amount');
    final paid = payments.fold<num>(0, (sum, row) => sum + ((row['amount'] as num?) ?? 0));
    return {'fees': totalFees, 'paid': paid, 'remaining': totalFees - paid};
  }
}
