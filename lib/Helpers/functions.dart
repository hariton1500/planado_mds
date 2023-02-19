String getJobPeriod(String data, int mins) {
  print(data);
  DateTime date = DateTime.parse(data);
  return '${date.hour}:${date.minute} - $mins';
}