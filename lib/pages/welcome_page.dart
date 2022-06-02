
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ttwihtt/data/data.dart';
import 'package:ttwihtt/main.dart';
import 'package:ttwihtt/utils/get_widget_utils.dart';
import 'package:ttwihtt/utils/utils.dart';
import 'package:ttwihtt/utils/values_utils.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  Data data;

  Future<bool> init(BuildContext buildContext)async{
    if(data==null){
      data= await Data.initData(buildContext, 'welcome page');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Welcome to 2TWIHTT'),
      body: FutureBuilder(
        future: init(context),
        builder: (context, snapshot) {
          if(snapshot.hasData){
             return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getPadding(SvgPicture.asset(AssetsPath.welcomeIcon),horizontal: 20,vertical: 20),
                  getSignInWithGoogleButton(data.loginHelper,context),
                  getButton('Sign in later',variant: 2,onPressed: (){
                    launchPage(context, HomePage());
                  }),
                ],   
              ),
            );
          }else{
            return Center(child: CircularProgressIndicator(),);
          }
        }
      ),
    );
  }
}