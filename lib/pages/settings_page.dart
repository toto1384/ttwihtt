import 'package:flutter/material.dart';
import 'package:ttwihtt/data/prefs.dart';
import 'package:ttwihtt/icon_pack_icons.dart';
import 'package:ttwihtt/main.dart';
import 'package:ttwihtt/utils/get_widget_utils.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Settings',context: context,backEnabled: true),
      body: FutureBuilder(
        future: Prefs.getInstance(),
        builder: (BuildContext ctx,AsyncSnapshot<Prefs> snap){
          if(snap.hasData){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: getText('Dark mode'),
                    leading: getIcon(IconPack.moon),
                    onTap: ()async{
                      await snap.data.setDarkMode();
                      MyApp.restartApp(context);
                      setState(() {
                        
                      });
                    },
                  ),     
                ],
              ),
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }
}