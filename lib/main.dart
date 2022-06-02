import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:ttwihtt/data/data.dart';
import 'package:ttwihtt/data/prefs.dart';
import 'package:ttwihtt/icon_pack_icons.dart';
import 'package:ttwihtt/pages/settings_page.dart';
import 'package:ttwihtt/pages/welcome_page.dart';
import 'package:ttwihtt/utils/date_utils.dart';
import 'package:ttwihtt/utils/get_popup_and_sheets_utils.dart';
import 'package:ttwihtt/utils/get_widget_utils.dart';
import 'package:ttwihtt/utils/typedef_and_enums_utils.dart';
import 'package:ttwihtt/utils/utils.dart';
import 'package:ttwihtt/widgets/todo_widget.dart';
import 'objects/todo.dart';

void main() {
  Prefs.getInstance().then((prefs){
    runApp(MyApp(prefs.getTimesOpened()==0,prefs.getDarkMode()));
  });
}

class MyApp extends StatefulWidget{

  static bool isDarkMode = false;
  static bool firstTime = true;

  MyApp(bool first,bool dark){
    isDarkMode=dark;
    firstTime=first;
  }

  static restartApp(BuildContext context) {
    final MyAppState state =
        context.findAncestorStateOfType<MyAppState>();
    state.restartApp();
  }

  @override
  MyAppState createState() {
    return MyAppState();
  }

}

class MyAppState extends State<MyApp>{

  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: '2TWIHTT',
        theme: getAppTheme(),
        darkTheme: getAppDarkTheme(),
        home: MyApp.firstTime?WelcomePage():HomePage(),
        debugShowCheckedModeBanner: false,
        themeMode: MyApp.isDarkMode?ThemeMode.dark:ThemeMode.light,
    );
  }


}


class HomePage extends StatefulWidget {

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {


  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<Todo> todos;
  Data data;

  bool isPopupShown = false;

  static int page= 0;
  PageController pageController = PageController(
    initialPage: page,
  );

  init()async{

    if(data==null){
      data = await Data.initData(context,'home page if null');
    }

    if(todos==null){
      todos = await data.backend.getTodos();
      print('Todos got');
    }


    return true;
  }

  @override
  void afterFirstLayout(BuildContext context) {
   if(!MyApp.firstTime){
     showDistivityDialog(context,
      actions: [getButton('Close',variant: 2,onPressed: ()=>Navigator.pop(context))],
      stateGetter: (ctx,ss){
        return getTipWidget();
      },
      title: 'Tip of the day');
   }
  }



  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: getFloatingActionButton(FABAction.AddTask,onPressed: (){showAddTaskBottomBar(buildContext);}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: getBottomAppBar(onPressed: (){showMoreBottomSheet(buildContext);}),
      body: FutureBuilder(
        future: init(),
        builder: (ctx,snap){

          if(snap.hasData){

            Map<int,List<int>> todoIndexes = Map();

            return PageView.builder(
              onPageChanged: (val){
                setState(() {
                  page = val;
                });
              },
              controller: pageController,
              itemCount: 8,
              itemBuilder: (ctx,index){
                if(todoIndexes[index]==null){
                  if(index==0){
                    todoIndexes[0]=List.generate(todos.length, (index){return index;});
                  }else {
                    todoIndexes[index]= filterTodosByDate(todos,DateTime.now().add(Duration(days: index-1)));
                  }
                }

                List<int> currentTodoIndexes = todoIndexes[index];

                if(currentTodoIndexes.length>0){

                  return ListView.builder(
                    itemCount:currentTodoIndexes.length,
                    itemBuilder: (ctx,index){

                      Todo curentTodo = todos[currentTodoIndexes[index]];

                      return TodoWidget(todo: curentTodo,
                        onTodoUpdate: (todo){
                          updateTodo(todo,currentTodoIndexes[index]);
                        },
                        openEditBottomSheet: (){openEditTodoBottomSheet(currentTodoIndexes[index],buildContext);},
                      );

                    },
                  );

                }else{
                  return getEmptyView();
                }
              },
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      appBar: getAppBar(getAppBarName(),),
    );
  }

  addTodo(Todo todo)async{
    todo.id= await data.backend.addTodo(todo);
    print('added todo');
    setState(() {
      todos.add(todo);
    });
  }


  void showAddTaskBottomBar(BuildContext buildContext) {
    TextEditingController todoNameTextEditingController = TextEditingController();
    DateTime dateTime = page==0?null:DateTime.now().add(Duration(days: page-1));

    double importancyValue = 0;
    double timeValue = 0;
    int color = 0;

    showDistivityModalBottomSheet(buildContext, (ctx,ss){

      return getPadding(Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                getTextField(todoNameTextEditingController,textInputType: TextInputType.text,width: 250,hint: 'Fight bears,Go to the moon',focus: true),
                getPadding(IconButton(
                    icon: getIcon(IconPack.send),
                    onPressed: ()async{
                      addTodo(Todo(color: color,
                                checked: false,
                                importancy: importancyValue.toInt(),
                                name: todoNameTextEditingController.text,
                                timeRequired: timeValue.toInt(),
                                childs: null, dueDate: dateTime));
                      Navigator.pop(buildContext);
                    },
                  ),horizontal: 8,vertical: 0)
              ],
            ),  
            getPadding(getText('Importancy',textType: TextType.textTypeSubtitle),),
            Slider.adaptive(
              value: importancyValue,
              onChanged: (newVal){
                ss(() {
                  importancyValue = newVal;
                });
              },
              label: '$importancyValue',
              min: 0,
              max: 100,
            ),
            getPadding(getText('Time required',textType: TextType.textTypeSubtitle),),
            Slider.adaptive(
              value: timeValue,
              onChanged: (newVal){
                ss(() {
                  timeValue = newVal;
                });
              },
              label: getTimeLabel(timeValue),
              divisions: 7,
              min: 0,
              max: 7,

            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                getPickDateButton(buildContext,dateTime: dateTime,onDateTimeSet: (val){
                  ss(() {
                    dateTime = val;
                  });
                }),
                getColorPickerButton(context,color,(val){
                  ss(() {
                    color=val;
                  });
                }),
              ],
            )
          ],
        ),);
    });
  }

  void showMoreBottomSheet(BuildContext buildContext) {

    showDistivityModalBottomSheet(buildContext, (ctx,ss){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: getText('Delete checked todos'),
            leading: getIcon(IconPack.trash),
            onTap: (){
              setState(() {
                List itemsToDelete = filterTodosByChecked(todos, true);
                itemsToDelete.forEach((item){
                  todos.remove(item);
                  data.backend.deleteTodo(item.id);
                  print('deleted todo');
                });
              });
              Navigator.pop(buildContext);
            },
          ),
          ListTile(
            title: getText('Settings'),
            leading: getIcon(IconPack.settings),
            onTap: (){
              Navigator.pop(context);
              launchPage(buildContext, SettingsPage());
            },
          ),
          ListTile(
            title: getText('Rate :)'),
            leading: getIcon(IconPack.star),
            onTap: (){
              LaunchReview.launch();
            },
          ),
          ListTile(
            title: getText('Send feedback'),
            leading: getIcon(IconPack.feedback),
            onTap: (){
              showFeedbackBottomSheet(buildContext);
            },
          ),
          getSignInOutListTile(context, data.loginHelper),
        ],
      );
    });

  }
  void openEditTodoBottomSheet(int index,BuildContext buildContext) {

    Todo curentTodo = todos[index];
    showDistivityModalBottomSheet(buildContext, (ctx,ss){

      TextEditingController nameTextEditingController = TextEditingController(text: curentTodo.name);

      GlobalKey colorGK = GlobalKey();
      GlobalKey importancyGK = GlobalKey();
      GlobalKey timeGK = GlobalKey();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getPadding(
                getTextField(
                  nameTextEditingController,
                  textInputType: TextInputType.text,
                  width: 300,
                  focus: false,
                  hint: 'Fight bears, Go to the moon',
                  variant: 2,
                  onChanged: (str){
                    curentTodo.name = nameTextEditingController.text;
                    todos[index] = curentTodo;
                  }
                ),
                horizontal: 8,vertical: 15,
              ),
              getPadding(
                IconButton(
                  icon: getIcon(IconPack.send),
                  onPressed: (){
                    curentTodo.name = nameTextEditingController.text;
                    updateTodo(curentTodo, index);
                    Navigator.pop(buildContext);
                  },
                )
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[

              getWidgetKey(colorGK, getColorPickerButton(context, curentTodo.color, (val){ss(() {curentTodo.color=val;updateTodo(curentTodo, index);});}),),

              getWidgetKey(importancyGK, IconButton(
                  icon: getIcon(IconPack.effort_icon),
                  onPressed: (){
                    showDistivityPopupMenu(context,above: true,globalKey: importancyGK,popupContentBuilder: (ctx,close){
                      return getSliderWrapperForSuperTooltip(getSlider: (ctx,sliderSetState){
                        return Slider.adaptive(
                          value: curentTodo.importancy.toDouble(),
                          onChanged: (newVal){
                            sliderSetState(() {
                              curentTodo.importancy = newVal.toInt();
                              updateTodo(curentTodo, index);
                            });
                          },
                          onChangeEnd: (val){
                            close();
                          },
                          label: '${curentTodo.importancy.toDouble()}',
                          min: 0,
                          max: 100,
                        );
                      },title: 'Importancy');
                    });
                  },
                )
              ,),

              getWidgetKey(timeGK, IconButton(
                  icon: getIcon(IconPack.timer),
                  onPressed: (){
                    showDistivityPopupMenu(context,globalKey: timeGK,above: true,popupContentBuilder: (ctx,close){
                      return getSliderWrapperForSuperTooltip(getSlider: (ctx,sliderSetState){
                        return Slider.adaptive(
                          value: curentTodo.timeRequired.toDouble(),
                          onChanged: (newVal){
                            sliderSetState(() {
                              curentTodo.timeRequired = newVal.toInt();
                              updateTodo(curentTodo, index);
                            });
                          },
                          onChangeEnd: (val){
                            close();
                          },
                          label: getTimeLabel(curentTodo.timeRequired.toDouble()),
                          divisions: 7,
                          min: 0,
                          max: 7,

                        );
                      },title:'Time required');
                    });
                  },
                )
              ),


              getPickDateButton(buildContext,dateTime: curentTodo.dueDate,onDateTimeSet: (val){
                ss(() {
                  curentTodo.dueDate= val;
                });
                updateTodo(curentTodo, index);
              }),

              PopupMenuButton(
                icon: getIcon(IconPack.dots_vertical),
                itemBuilder: (ctx){
                  return <PopupMenuItem>[
                    getPopupMenuItem(
                      value: 0,
                      iconData: IconPack.duplicate,
                      name: 'Duplicate task',
                    ),
                    getPopupMenuItem(
                      value: 1,
                      iconData: IconPack.trash,
                      name: 'Delete task'
                    )
                  ];
                },
                onSelected: (val)async{
                  switch(val){
                    case 0:  
                      setState(() async{
                        todos.add(await curentTodo.duplicateAndInsert(data.backend));
                      });
                      print('on item dupl snack');
                      scaffoldKey.currentState.showSnackBar(SnackBar(content: getText('Item duplicated'),));
                      break;
                    case 1: deleteTodo(index);
                      Navigator.pop(buildContext);
                      print('on item delete snack');
                      scaffoldKey.currentState.showSnackBar(SnackBar(content: getText('Item deleted'),));
                      break;
                  }
                },
              ),

            ],
          ),
          Divider(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(curentTodo.childs.length, (subTaskIndex){

              TextEditingController nameSubtaskTextEditingController = TextEditingController(text: curentTodo.childs[subTaskIndex].name);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      getPadding(
                        getFlareCheckbox(curentTodo.childs[subTaskIndex].checked,
                          onCallbackCompleted:(checked){
                            updateTodo(curentTodo,index); 
                          },
                          onTap: (){
                            ss(() {
                              curentTodo.childs[subTaskIndex].checked=!curentTodo.childs[subTaskIndex].checked;
                            });
                        }),
                      ),
                      getTextField(
                        nameSubtaskTextEditingController,
                        textInputType: TextInputType.text,
                        width: 200,
                        focus: false,
                        hint: 'Subtask',
                        variant: 2,
                        onChanged: (str){
                          curentTodo.childs[subTaskIndex].name=str;
                          todos[index]= curentTodo;
                        }
                      ),
                    ],
                  ),
                  IconButton(
                    icon: getIcon(IconPack.trash,size: 16),
                    onPressed: (){
                      ss(() {
                        curentTodo.childs.removeAt(subTaskIndex);
                      });
                      updateTodo(curentTodo, index);
                    },
                  ),


                ],
              );
            })+[
              getPadding(
                 ListTile(
                  leading: getIcon(IconPack.add),
                  title: getText('Add subtask'),
                  onTap: (){
                    ss(() {
                      curentTodo.childs.add(Subtask(false, ''));
                      updateTodo(curentTodo, index);
                    });
                  },
                )
              )
            ],
          )
        ],
      );
    },);
  }


  void updateTodo(Todo todo,int index) {
    setState(() {
      todos[index] = todo;
      data.backend.updateTodo(todo);
      print('updated todo');
    });
  }

  void deleteTodo(int index) {
    setState(() {
      data.backend.deleteTodo(todos[index].id);
      todos.removeAt(index);
      print("delete todo");
    });
  }

  String getAppBarName() {
    switch (page){
      case 0: return 'All Tasks';
      case 1: return 'Today';
      case 2: return 'Tomorrow';
      default: return getStringFromDate(DateTime.now().add(Duration(days: page-1)));
    }
  }

}