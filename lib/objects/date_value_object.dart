

import 'package:ttwihtt/utils/date_utils.dart';

class DateValueObject{
  int value;
  DateTime dateTime;

  DateValueObject(this.dateTime,this.value);


  Map<String,dynamic> toMap(){
    return {
      'value':value,
      'date':getStringFromDate(dateTime),
    };
  }

  static DateValueObject fromMap(Map map){
    return DateValueObject(
      getDateFromString(map['date']),map['value']
    );
  }
}