import '../core/utils/format.dart';

class Payment {
  const Payment({required this.id, required this.amount, required this.status, required this.reference, required this.applicationNumber, this.dueDate, this.proofPath, this.paidOn});
  final String id, status, reference, applicationNumber;
  final num amount;
  final DateTime? dueDate, paidOn;
  final String? proofPath;

  bool get hasProof => proofPath != null && proofPath!.isNotEmpty;

  factory Payment.fromMap(Map<String, dynamic> m, String applicationNumber) => Payment(
        id: m['payment_id'] as String,
        amount: num.tryParse('${m['amount']}') ?? 0,
        status: (m['payment_status'] ?? 'Awaiting Payment') as String,
        reference: (m['payment_reference'] ?? '') as String,
        applicationNumber: applicationNumber,
        dueDate: parseDate(m['due_date']),
        proofPath: m['proof_of_payment'] as String?,
        paidOn: parseDate(m['payment_date']),
      );
}

class BankDetails {
  const BankDetails({required this.bank, required this.holder, required this.account, required this.branch});
  final String bank, holder, account, branch;

  factory BankDetails.fromMap(Map<String, dynamic> m) => BankDetails(
        bank: (m['bank_name'] ?? '') as String,
        holder: (m['account_holder'] ?? '') as String,
        account: (m['account_number'] ?? '') as String,
        branch: (m['branch_code'] ?? '') as String,
      );
}
