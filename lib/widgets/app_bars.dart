import 'package:flutter/material.dart';

/// AppBar hitam standar untuk halaman dalam.
AppBar blackAppBar(
  String title, {
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    actions: actions,
    bottom: bottom,
  );
}
