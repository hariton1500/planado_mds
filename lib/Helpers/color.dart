import 'package:flutter/material.dart';

Color colorOfJob(String status, bool? isSuccessful) {
  switch (status) {
    case 'published':
      return Colors.blue;
    case 'suspended':
      return Colors.grey;
    case 'en_route':
      return Colors.indigo;
    case 'started':
      return Colors.green[200]!;
    case 'finished':
      return isSuccessful != null && isSuccessful ? Colors.green : Colors.red;
    default:
      return Colors.blue;
  }
}

IconData getJobIcon(String type) {
  switch (type) {
    case 'Подключение в многоэтажке':
      return Icons.plus_one;
    default:
      return Icons.construction;
  }
}
