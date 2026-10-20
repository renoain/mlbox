import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EditTextPage extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;

  const EditTextPage({super.key, required this.initial, required this.onChanged});

  @override
  State<EditTextPage> createState() => _EditTextPageState();
}

class _EditTextPageState extends State<EditTextPage> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _apply(String text, TextSelection selection) {
    _c.value = TextEditingValue(text: text, selection: selection);
    widget.onChanged(text);
  }

  void _wrap(String marker) {
    final sel = _c.selection;
    if (!sel.isValid) return;
    final t = _c.text;
    final s = t.substring(sel.start, sel.end);
    _apply(
      t.replaceRange(sel.start, sel.end, '$marker$s$marker'),
      TextSelection(
        baseOffset: sel.start + marker.length,
        extentOffset: sel.end + marker.length,
      ),
    );
  }

  void _quote() {
    final sel = _c.selection;
    final t = _c.text;
    final at = sel.isValid ? sel.start : t.length;
    _apply(
      t.replaceRange(at, at, '> '),
      TextSelection.collapsed(offset: at + 2),
    );
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
          'Edit Text',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _c,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add review\u2026',
                  hintStyle: TextStyle(color: AppColors.muted),
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ),
          Container(
            color: AppColors.surface,
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => _wrap('**'),
                  icon: const Icon(Icons.format_bold, color: AppColors.muted),
                ),
                IconButton(
                  onPressed: () => _wrap('*'),
                  icon: const Icon(Icons.format_italic, color: AppColors.muted),
                ),
                IconButton(
                  onPressed: _quote,
                  icon: const Icon(Icons.format_quote, color: AppColors.muted),
                ),
                const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.link, color: AppColors.starOff),
                ),
                const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.undo, color: AppColors.starOff),
                ),
                const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.redo, color: AppColors.starOff),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
