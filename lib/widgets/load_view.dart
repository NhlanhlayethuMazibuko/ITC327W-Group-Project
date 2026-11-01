import 'package:flutter/material.dart';
import '../core/core.dart';
import 'app_button.dart';
import 'error_message.dart';

/// Loads data once, shows a spinner or a retry button, then builds the content.
class LoadView<T> extends StatefulWidget {
  const LoadView({super.key, required this.loader, required this.builder});
  final Future<T> Function() loader;
  final Widget Function(BuildContext context, T data, Future<void> Function() reload) builder;

  @override
  State<LoadView<T>> createState() => _LoadViewState<T>();
}

class _LoadViewState<T> extends State<LoadView<T>> {
  T? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final d = await widget.loader();
      if (mounted) setState(() => _data = d);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: AppColors.orange)));
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [ErrorMessage(_error), SizedBox(width: 160, child: AppButton(label: 'Try again', onPressed: _load))]),
      );
    }
    return widget.builder(context, _data as T, _load);
  }
}
