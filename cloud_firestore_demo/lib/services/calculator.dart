import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Calculator{

  /// DateTime zaman biçimini --> Stringe formatlayıp çeviren
  static String dateTimeToString(DateTime dateTime){
    String formatedDate = DateFormat("dd/ MM/ yyyy").format(dateTime);
    return formatedDate;
  }

  /// DateTime --> TimeStamp dönüştürme
  static Timestamp datetimeToTimestamp(DateTime dateTime){
    return Timestamp.fromMicrosecondsSinceEpoch(dateTime.millisecondsSinceEpoch);
  }


  /// TimeStamp --> DateTime dönüştürme
  static DateTime dateTimeFromTimestamp(Timestamp timestamp){
    return DateTime.fromMicrosecondsSinceEpoch(timestamp.seconds*1000);
  }

}