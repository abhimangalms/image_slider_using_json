import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_id/device_id.dart';
import 'package:http/http.dart' as http;
import 'package:image_slider_using_json/common_functions.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:async/async.dart';

class ApiCalls {
  final String base_url = 'http://loyal.sreyassolutions.com/api/';
  CommonFunctions commonFunctionsObj = new CommonFunctions();

  getImageSliders() async {
    final String url = "http://booking.sreyas.net/api/sliderData";
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List list = json.decode(response.body);

      if (response.body.contains("imgUrl")) {
        //check if images exist
        print("Image exist");
        print(response.body);
        var lst = new List(list.length);

        for (int i = 0; i < list.length; i++) {
          var imgUrl = list[i]['imgUrl'];
          lst[i] = 'http://booking.sreyas.net$imgUrl';
        }

        return lst;
      } else {
        print("no image found");
      }
    } else {
      print("Something error occuresd");
    }
  }

  signIn(String username, password, fcmToken, BuildContext context) async {
    String deviceId = await DeviceId.getID; //getting device unique id
    debugPrint(
        '*********************deviceId is*********************: $deviceId');

    Map data = {
      'username': username,
      'password': password,
      'device_id': deviceId,
      'fcm_token': fcmToken
    };

    final String url = base_url + "/login";

    var response = await http.post(url, body: data);
    var responseValue = getResponse(context, response);
    return responseValue;
  }

  getMyProfile(BuildContext context) async {
    final String url = base_url + "/profile";

    String api_key = await commonFunctionsObj.getApiToken();
    Map<String, String> headers = new HashMap();
    print('api_token is $api_key');

    headers.putIfAbsent(
        'Authorization', () => api_key); //result is having the api_token

    print('header is $headers');
    var response = await http.get(
      url,
      headers: headers,
    );

    var responseValue = getResponse(context, response);
    return responseValue;
  }

  changePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
  ) async {
    final String url = base_url + "/change_password";

    String api_key = await commonFunctionsObj.getApiToken();

    Map data = {
      'old_password': currentPassword,
      'new_password': newPassword,
    };

    Map<String, String> headers = new HashMap();

    headers.putIfAbsent(
        'Authorization', () => api_key); //result is having the api_token

    var response = await http.post(url, body: data, headers: headers);
    var jsonResponse = null;

    jsonResponse = json.decode(response.body);
    var status = jsonResponse["status"]; //true or false

    var responseValue = getResponse(context, response); //result body
    return status;
  }

  updateProfile(
      BuildContext context,
      String newFirstName,
      String newLastName,
      String newEmail,
      String newPhone,
      String newAddress,
      File imageFile) async {
    var uri = Uri.parse(base_url + "/update_profile");
//    var uri = Uri.parse(base_url + "/image_upload");
    String api_key = await commonFunctionsObj.getApiToken();
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));

    var length = await imageFile.length();
    var request = new http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': api_key
    };
//    Map<String, String> headers = {'Authorization': api_key};

    request.headers.addAll(headers);

    request.fields['first_name'] = newFirstName;
    request.fields['last_name'] = newLastName;
    request.fields['email'] = newEmail;
    request.fields['phone'] = newPhone;
    request.fields['address'] = newAddress;

    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);

      var responseValue = getResponse(context, response);
      return responseValue;
    });
  }

  //this is the Server response commom functions
  getResponse(BuildContext context, var response) {
    var jsonResponse = null;

    if (response.statusCode == 200) {
      print(response.body);
      jsonResponse = json.decode(response.body);
      var status = jsonResponse["status"]; //status response

      if (status) {
        //if status is true

        print('status true');

        var resultJson = jsonResponse["result"];
        return resultJson; //returning response to the previous funcion

      } else {
        print('Error occured');
        print(response.body);
        commonFunctionsObj.showSimpleFlushbar(context, "Some error occured");
      }
    } else {
      print("Server error");
    }
  }
}
