/*

      String month = (DateTime.now().month < 10)
          ? '0${DateTime.now().month}'
          : DateTime.now().month.toString();
      String day = (DateTime.now().day < 10)
          ? '0${DateTime.now().day}'
          : DateTime.now().day.toString();

*/



String getJobPeriod(String data, int mins) {
  print(data);
  DateTime startDate = DateTime.parse(data).toLocal();
  return '${get0befor(startDate.hour)}:${get0befor(startDate.minute)} - ${get0befor(startDate.add(Duration(minutes: mins)).hour)}:${get0befor(startDate.add(Duration(minutes: mins)).minute)}';
}

String get0befor(int data){
  if (data < 10) {
    return '0$data';
  } else {
    return data.toString();
  }
}