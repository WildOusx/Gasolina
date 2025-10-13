// Small helper widget for chips used in the day details modal (ChipInfo)

import 'package:flutter/material.dart';

class ChipInfo extends StatelessWidget {
  const ChipInfo(this.icon, this.label, {super.key});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Chip(avatar: Icon(icon, size: 16), label: Text(label));
}
