import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonFunctions {
//  final String base_url = 'test_url';
  final String api_url = 'http://loyal.sreyassolutions.com/api/';

   checkInternetState() async {
    if (await DataConnectionChecker().hasConnection == true) {
      print("Network connected");
      return true;
    } else {
      print("Turn on your internet");
      return false;
    }
  }

  void showSimpleFlushbar(BuildContext context, String thisMessage) async{
    Flushbar(
      message: thisMessage,
      duration: Duration(seconds: 3),
    )..show(context);
  }

  getApiToken() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(sharedPreferences.containsKey("api_token")){

      String api_token = sharedPreferences.getString("api_token"); //getting stored fcm token id from sharedPreferences
      return api_token;
    }
    else{
      return null;
    }


  }

}
