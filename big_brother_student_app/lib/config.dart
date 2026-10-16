class Config {
  static const url = 'https://gtpujwmtglyffnzhbklo.supabase.co';
  // flutter run --dart-define=SUPABASE_ANON_KEY=your_anon_key
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static bool get configured => anonKey.isNotEmpty;

  // Banking details shown on the payment screen (simulated payments - proof of payment upload)
  static const bankHolder = 'Big Brother Student Accomodation';
  static const bank = 'FNB(First National Bank)';
  static const accountNo = '6291 0384 7721';
  static const branchCode = '250655';
}
