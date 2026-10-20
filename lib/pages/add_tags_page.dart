import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AddTagsPage extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;

  const AddTagsPage({super.key, required this.initial, required this.onChanged});

  @override
  State<AddTagsPage> createState() => _AddTagsPageState();
}

class _AddTagsPageState extends State<AddTagsPage> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Tags',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            controller: _c,
            autofocus: true,
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              labelText: 'Enter tags separated by commas',
              labelStyle: TextStyle(color: AppColors.muted, fontSize: 13),
              border: InputBorder.none,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
