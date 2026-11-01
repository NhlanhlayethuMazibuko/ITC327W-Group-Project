import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../home/main_shell.dart';

class _PayData {
  const _PayData(this.payment, this.bank);
  final Payment? payment;
  final BankDetails? bank;
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  UploadFile? _file;
  bool _submitting = false;
  String? _error;

  Future<_PayData> _load() async => _PayData(await PaymentService().current(), await PaymentService().bankDetails());

  Future<void> _pick() async {
    try {
      final f = await StorageService().pick();
      if (f != null) setState(() => _file = f);
    } catch (e) {
      setState(() => _error = friendlyError(e));
    }
  }

  Future<void> _submit(Payment p) async {
    if (_file == null) { setState(() => _error = 'Please upload your proof of payment first.'); return; }
    setState(() { _submitting = true; _error = null; });
    try {
      await PaymentService().submitProof(p.id, _file!);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ProofUploadedScreen(fileName: _file!.name)));
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Text('$k  ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), Expanded(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11)))]),
      );

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Payment',
      child: LoadView<_PayData>(
        loader: _load,
        builder: (context, data, _) {
          final p = data.payment;
          if (p == null) return const EmptyState(icon: Icons.payments_outlined, message: 'No payment is due yet.\nYou will be notified once your application is approved.');
          if (p.hasProof) return ProofSummary(payment: p);
          final days = p.dueDate?.difference(DateTime.now()).inDays;
          return Column(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFFE9C7), borderRadius: BorderRadius.circular(8)),
              child: Text('Your application ${p.applicationNumber} has been approved! Pay the amount below via EFT and upload proof of payment to secure your space.', style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Amount Due', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                  Text(money(p.amount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Payment Method: Bank Transfer/EFT', style: TextStyle(fontSize: 10)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Payment Due Date', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                  Text(p.dueDate == null ? '-' : fmtDate(p.dueDate!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  if (days != null) Text('${days < 0 ? 0 : days} Days Left', style: const TextStyle(fontSize: 10, color: AppColors.orangeDark)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            if (data.bank != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  const Align(alignment: Alignment.centerLeft, child: Text('Account Details:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  _kv('Account holder:', data.bank!.holder),
                  _kv('Bank:', data.bank!.bank),
                  _kv('Account number:', data.bank!.account),
                  _kv('Branch code:', data.bank!.branch),
                  _kv('Payment reference:', p.applicationNumber),
                ]),
              ),
            const SizedBox(height: 12),
            UploadTile(label: 'Proof of Payment', hint: 'PDF, JPG or PNG, up to 5 MB', file: _file, onPick: _pick),
            ErrorMessage(_error),
            AppButton(label: 'Submit', loading: _submitting, onPressed: () => _submit(p)),
            const SizedBox(height: 8),
            AppButton(label: 'Cancel', outlined: true, onPressed: () => Navigator.of(context).pop()),
          ]);
        },
      ),
    );
  }
}

/// Shared by the payment screen (already uploaded) and the confirmation screen.
class ProofSummary extends StatelessWidget {
  const ProofSummary({super.key, required this.payment, this.fileName});
  final Payment payment;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Your proof of payment is under review. Management will confirm once the payment has been received.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.muted)),
      const SizedBox(height: 12),
      if (payment.reference.isNotEmpty) ...[
        const Text('Your Reference Code:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Container(width: double.infinity, margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.symmetric(vertical: 10), color: const Color(0xFFFFF0D5),
            child: Text(payment.reference, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
      ],
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text('Amount', style: TextStyle(fontSize: 10, color: AppColors.muted)), const Spacer(), StatusChip(payment.status)]),
          Text(money(payment.amount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Payment method: Bank Transfer/EFT', style: TextStyle(fontSize: 11)),
          Text('Application: ${payment.applicationNumber}', style: const TextStyle(fontSize: 11)),
          if (payment.paidOn != null) Text('Submitted: ${fmtDate(payment.paidOn!)}', style: const TextStyle(fontSize: 11)),
          if (fileName != null) Text('File: $fileName', style: const TextStyle(fontSize: 11)),
        ]),
      ),
    ]);
  }
}

class ProofUploadedScreen extends StatelessWidget {
  const ProofUploadedScreen({super.key, required this.fileName});
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Proof of Payment Uploaded',
      showBack: false,
      child: Column(children: [
        const CircleAvatar(radius: 36, backgroundColor: Color(0xFFFFE0B2), child: Icon(Icons.check_circle, size: 50, color: AppColors.orange)),
        const SizedBox(height: 12),
        LoadView<Payment?>(
          loader: PaymentService().current,
          builder: (context, p, _) => p == null ? const SizedBox.shrink() : ProofSummary(payment: p, fileName: fileName),
        ),
        const SizedBox(height: 16),
        AppButton(label: 'View Application', onPressed: () => openShell(context, tab: 2)),
      ]),
    );
  }
}
