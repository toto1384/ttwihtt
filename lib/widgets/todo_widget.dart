
import 'package:flutter/material.dart';
import 'package:ttwihtt/icon_pack_icons.dart';
import 'package:ttwihtt/main.dart';
import 'package:ttwihtt/objects/todo.dart';
import 'package:ttwihtt/utils/get_widget_utils.dart';
import 'package:ttwihtt/utils/utils.dart';
import 'package:ttwihtt/utils/values_utils.dart';

class TodoWidget extends StatefulWidget {

  final Todo todo;
  final Function(Todo todo) onTodoUpdate;
  final Function openEditBottomSheet;


  TodoWidget({Key key,@required this.todo,@required this.onTodoUpdate,@required this.openEditBottomSheet}) : super(key: key);

  @override
  _TodoWidgetState createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {



  @override
  Widget build(BuildContext context) {

    double opacity = widget.todo.importancy/100;

    if(opacity<0.1){
      opacity=0.1;
    }


      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: (){
            widget.openEditBottomSheet();
          },
          child: Container(
            height: 50*(widget.todo.timeRequired+1).toDouble(),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: getColorValue(widget.todo.color).withOpacity(opacity)),
            child: Center(
              child: ListTile(
                leading: getFlareCheckbox(widget.todo.checked,
                  onCallbackCompleted:(checked){
                    widget.onTodoUpdate(widget.todo); 
                  },
                  onTap: (){
                    setState(() {
                      widget.todo.checked=!widget.todo.checked;
                    });
                  } ),
                title: getText(widget.todo.name,color: MyApp.isDarkMode?Colors.white:widget.todo.importancy<50?MyColors.color_black:Colors.white),
                trailing: Visibility(
                  visible: widget.todo.childs.length!=0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(IconPack.child,color: MyApp.isDarkMode?Colors.white:widget.todo.importancy<50?MyColors.color_black:Colors.white,size: 16,),
                      getText('${widget.todo.childs.length}',color: MyApp.isDarkMode?Colors.white:widget.todo.importancy<50?MyColors.color_black:Colors.white,)
                    ],
                  ),
                ),
              ),
            )
          ),
        ),
      );
  }

}