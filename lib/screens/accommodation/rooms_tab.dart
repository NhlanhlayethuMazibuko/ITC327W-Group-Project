import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_text.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_message.dart';
import '../../widgets/inner_scaffold.dart';
import '../../widgets/room_widgets.dart';
import 'unit_details_screen.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key, required this.query});
  final ValueNotifier<String> query;

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  final _service = RoomService();
  List<Room> _rooms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rooms = await _service.fetchRooms();
      if (!mounted) return;
      setState(() => _rooms = rooms);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: 'Available Rooms',
      showBack: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text('Choose the perfect room to suit your lifestyle and budget',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Expanded(child: _body()),
      ]),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [ErrorMessage(_error), SizedBox(width: 160, child: AppButton(label: 'Try again', onPressed: _load))]),
      );
    }
    return ValueListenableBuilder<String>(
      valueListenable: widget.query,
      builder: (context, q, _) {
        final term = q.trim().toLowerCase();
        final shown = term.isEmpty
            ? _rooms
            : _rooms.where((r) => r.name.toLowerCase().contains(term) || r.type.toLowerCase().contains(term)).toList();
        if (shown.isEmpty) {
          return EmptyState(icon: Icons.bed_outlined, message: term.isEmpty ? 'No rooms are listed yet.' : 'No rooms match "$q".');
        }
        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: shown.length,
            itemBuilder: (_, i) => RoomListCard(
              room: shown[i],
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UnitDetailsScreen(room: shown[i]))),
            ),
          ),
        );
      },
    );
  }
}
