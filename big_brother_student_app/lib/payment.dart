import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'application.dart' show pickFile;
import 'config.dart';
import 'state.dart';
import 'ui.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentState();
}

class _PaymentState extends State<PaymentScreen> {
  String method = 'Bank Transfer/EFT';
  PlatformFile? proof;
  bool busy = false;

  Widget _kv(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), Text(v, style: const TextStyle(fontSize: 16))]));

  @override
  Widget build(BuildContext context) {
    final a = app.application;
    final ref = (a?['application_number'] ?? 'BB-APP-2026-0000') as String;
    final due = DateTime.now().add(const Duration(days: 7));
    return PageShell(
      navIndex: 2,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
        const Center(child: Text('Payment', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kSand, borderRadius: BorderRadius.circular(20)),
              child: Text.rich(TextSpan(style: const TextStyle(fontSize: 17), children: [
                const TextSpan(text: 'Your application '),
                TextSpan(text: ref, style: const TextStyle(fontWeight: FontWeight.w800)),
                const TextSpan(text: ' has been approved! Pay the amount below via EFT or an alternative and upload proof of payment to secure your space.'),
              ])),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(22)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Amount Due', style: TextStyle(fontSize: 17)),
                  Text(money(app.amountDue), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  const Text('Payment Method', style: TextStyle(fontSize: 17)),
                  const SizedBox(height: 6),
                  DropdownButton<String>(
                    value: method,
                    items: const ['Bank Transfer/EFT', 'Cash deposit', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => method = v!),
                  ),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  const Text('Payment Due Date', style: TextStyle(fontSize: 17)),
                  Text('${due.day} ${['January','February','March','April','May','June','July','August','September','October','November','December'][due.month - 1]} ${due.year}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 14),
                  const CircleAvatar(radius: 18, backgroundColor: kOrangeTop, child: Text('7', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 4),
                  const Text('Days Left', style: TextStyle(fontSize: 17)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            const Text('Account Details:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(22)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(Config.bankHolder, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const Text('Account Holder', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                _kv('Bank:', Config.bank),
                _kv('Account Number:', Config.accountNo),
                _kv('Branch Code:', Config.branchCode),
                const SizedBox(height: 6),
                const Text('Payment Reference:'),
                Text(ref, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ]),
            ),
            const SizedBox(height: 12),
            UploadBox('Tap to upload Proof of Payment Here\n(PDF,JPG,PNG,JPEG)', proof?.name, () async { final f = await pickFile(ext: ['pdf', 'jpg', 'jpeg', 'png']); if (f != null) setState(() => proof = f); }, dashed: true),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OBtn('Cancel', outline: true, dark: true, onTap: () => Navigator.pop(context))),
          const SizedBox(width: 16),
          Expanded(child: OBtn('Submit', dark: true, loading: busy, onTap: () async {
            if (proof == null) return toast(context, 'Please upload your proof of payment.');
            setState(() => busy = true);
            final ok = await app.submitPayment(method, proof!);
            if (!mounted) return;
            setState(() => busy = false);
            if (ok) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaymentUploadedScreen())); } else { toast(context, 'Upload failed. Please try again.'); }
          })),
        ]),
      ]),
    );
  }
}

class PaymentUploadedScreen extends StatelessWidget {
  const PaymentUploadedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = app.payment ?? {};
    final t = (p['submitted'] as DateTime?) ?? DateTime.now();
    const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    Widget kv(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(fontSize: 16)), Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))]));
    return PageShell(
      navIndex: 2,
      child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), children: [
        const Center(child: Text('Proof of Payment Uploaded', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
        const SizedBox(height: 22),
        const Center(child: SuccessCheck()),
        const SizedBox(height: 10),
        const Center(child: Text('Thank you! Your payment is under review.', style: TextStyle(color: Colors.grey, fontSize: 16))),
        const SizedBox(height: 12),
        const Center(child: Text('Your Reference Code:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
        const SizedBox(height: 8),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), color: kPeach, child: Text('${p['reference_code'] ?? 'BB-PAY-0000'}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Amount Paid', style: TextStyle(fontSize: 16)), const Pill('Pending Verification', Colors.white, kOrange)]),
            Text(money((p['amount'] ?? 4500) as num), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            kv('Payment Method:', '${p['payment_method']}'),
            kv('Payment Reference:', '${p['payment_reference']}'),
            kv('Submitted:', '${t.day.toString().padLeft(2, '0')} ${mon[t.month - 1]} ${t.year}, ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: kSand, border: Border.all(color: Colors.black87, style: BorderStyle.solid), borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            const Icon(Icons.description_outlined, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${p['file'] ?? 'Proof_of_Payment.pdf'}', style: const TextStyle(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis), const Text('Uploaded Successfully!', style: TextStyle(color: Colors.black54))])),
            const Icon(Icons.check_circle_outline, size: 34),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OBtn('View Application', outline: true, dark: true, onTap: () => goTab(context, 2))),
          const SizedBox(width: 16),
          Expanded(child: OBtn('Submit', dark: true, onTap: () => goTab(context, 0))),
        ]),
      ]),
    );
  }
}
