

import 'package:flutter/cupertino.dart';
import 'package:ttwihtt/data/backend.dart';
import 'package:ttwihtt/utils/date_utils.dart';

class Todo{

    int id;
    String name;
    bool checked;
    int timeRequired;
    int importancy;
    List<Subtask> childs;
    DateTime dueDate;
    int color;


    Todo({this.id,@required this.color,@required this.name,@required this.checked,@required this.timeRequired, @required this.importancy,@required this.childs,@required this.dueDate});


    static fromMap(Map map){

      return Todo(checked: map[T_CHECKED]==1?true:false,id: map[T_ID],importancy: map[T_IMPORTANCY],name: map[T_NAME],timeRequired: map[T_TIME_REQUIRED],
        childs: getChilds(map[T_CHILDS]),dueDate: getDateFromString(map[T_DUEDATE]),color: map[T_COLOR]);

    }

    Future<Todo> duplicateAndInsert(Backend backend)async{
      Todo duplicated = Todo(
        color: color,
        childs: childs,
        checked: checked,
        importancy: importancy,
        name: 'Copy of $name',
        timeRequired: timeRequired,
        dueDate: dueDate);

      duplicated.id = await backend.addTodo(duplicated);
      print('todo added');

      return duplicated;
    }


    toMap(){


      if(childs==null){
        childs = List<Subtask>();
      }

      String childsString = '';

      childs.forEach((subtask){
        String valueString = '';

        if(subtask.checked){
          valueString = '•${subtask.name}';
        }else{
          valueString = subtask.name;
        }
        childsString = '$childsString,$valueString';
      });


      return {
        T_ID : id,
        T_NAME : name,
        T_CHECKED : checked?1:0,
        T_IMPORTANCY : importancy,
        T_TIME_REQUIRED: timeRequired,
        T_CHILDS: childsString,
        T_DUEDATE: dueDate==null?'':getStringFromDate(dueDate),
        T_COLOR: color,
      };
    }

  static getChilds(String str) {

    if(str == null||str.trim()==''){
      return List<Subtask>();
    }

    List<String> todos = str.split(',');

    List<Subtask> todosMap = List();

    todos.forEach((item){
      if(item!=''){
        if(item.contains('•')){
          item.replaceAll('•', '');

          todosMap.add(Subtask(true,item));
        }else{

          todosMap.add(Subtask(false, item));
        }
      }
    });

  return todosMap;

  }



}


class Subtask{
  bool checked;
  String name;
  Subtask(this.checked,this.name);
}

List filterTodosByDate(List<Todo> todos, DateTime dateTime){
  List<int> todosToReturn = List();

  for(int i = 0 ; i<todos.length;i++){
    Todo item = todos[i];
    if(item.dueDate==null){

    }else{
      if(item.dueDate.day==dateTime.day){
        todosToReturn.add(i);
      } 
    }
  }
  return todosToReturn;
}

List<Todo> filterTodosByChecked(List<Todo> todos, bool checked){
  List<Todo> todosToReturn = List();

  for(int i = 0 ; i<todos.length;i++){
    Todo item = todos[i];
    if(item.checked==checked){
      todosToReturn.add(item);
    }
  }
  return todosToReturn;
}





const TIME_LESS_THAN_5_MINUTES = 0;
const TIME_10_MINUTES = 1;
const TIME_30_MINUTES = 2;
const TIME_1_HOUR = 3;
const TIME_2_HOURS = 4;
const TIME_3_HOURS = 5;
const TIME_4_HOURS = 6;
const TIME_5_OR_MORE = 7;


const T_COLOR_DEFAULT = 0;
const T_COLOR_RED = 1;
const T_COLOR_YELLOW = 2;
const T_COLOR_PURPLE = 3;
const T_COLOR_GREEN = 4;
const T_COLOR_CYAN = 5;
const T_COLOR_ORANGE = 6;
const T_COLOR_CONTRAST = 7;


const T_CHECKED = 'ch';
const T_ID = '_id';
const T_NAME = 'na';
const T_TIME_REQUIRED = 'tr';
const T_IMPORTANCY = 'im';
const T_CHILDS = 'ci';
const T_DUEDATE = 'du';
const T_COLOR = 'co';
