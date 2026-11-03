import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/storage_service.dart';

class UploadTile extends StatelessWidget {
  const UploadTile({super.key, required this.label, required this.hint, required this.file, required this.onPick, this.onRemove});
  final String label, hint;
  final UploadFile? file;
  final VoidCallback onPick;

  /// Shown as an X once a file is chosen, so the student can clear it.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(file == null ? Icons.description_outlined : Icons.check_circle, color: file == null ? AppColors.text : const Color(0xFF1B7F3A)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(file?.name ?? hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          ]),
        ),
        SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: onPick,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: Text(file == null ? 'Upload' : 'Change', style: const TextStyle(fontSize: 11)),
          ),
        ),
        if (file != null && onRemove != null)
          IconButton(
            tooltip: 'Remove file',
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.text,
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
          ),
      ]),
    );
  }
}
