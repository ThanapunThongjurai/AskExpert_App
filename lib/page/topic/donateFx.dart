import 'dart:convert';

import 'package:askexpertapp/config/config.dart';
import 'package:askexpertapp/dataModel/topicDataModel.dart';
import 'package:askexpertapp/dataModel/userDataModel.dart';
import 'package:askexpertapp/page/topic/commentPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:askexpertapp/utils/storageToken.dart';

Future<void> tranferToken(
    String? ContentId, String? donatePoint, String? userIdReceiver) async {
  // print("ContentID : ${ContentID}  ");
  // print("donatePoint : ${donatePoint}");
  // print("userIdReceiver :  ${userIdReceiver}");

  Map<String, String> params = Map();
  //Map<String, String> data = Map();
  var body = jsonEncode({
    'tranAmount': int.parse(donatePoint!),
    'tranContentId': ContentId,
    'tranRx': userIdReceiver
  });
  String? _authen = await tokenStore.getToken();
  _authen = "Bearer " + _authen!;
  print("body : ${body}");
  print("_authen : ${_authen}");
  var url = Uri.parse('${ConfigApp.apiTransactionTransfer}');
  var response = await http.post(url, body: body, headers: {
    "Accept": "application/json",
    "content-type": "application/json",
    "Authorization": "${_authen}"
  });
  Map resMap = jsonDecode(response.body);

  print('\nResponse status: ${response.statusCode}');
  print('\nResponse message: ${resMap["message"]}');
  print('\nResponse body data: ${resMap["data"]}');

  if (response.statusCode == 200 && resMap["message"] == null) {
    Get.back();
  } else {

    print('\nResponse status: ${response.statusCode}');
    print('\nResponse message: ${resMap["message"]}');
    print('\nResponse body data: ${resMap["data"]}');
  }
}

Widget buildImageProfileDonateSheet(String index) => ClipRRect(
      // backgroundImage: CachedNetworkImageProvider(
      //   '${Config.imgProfile}$index',
      // ),
      borderRadius: BorderRadius.circular(100),
      child: CachedNetworkImage(
        imageUrl: '${ConfigApp.imgProfile}$index',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        // errorWidget: (context, url, error) => Container(
        //   color: Colors.black12,
        //   child: Icon(FontAwesomeIcons.person, color: Colors.black),
        // ), // Container
        //

        cacheManager: ConfigApp.profileCache,
        // maxHeightDiskCache: 100,
        // maxWidthDiskCache: 100,
      ),
    );

Future<void> donateSheet(
    String? contentId,
    String? contentCaption,
    String? userIdReceiver,
    String? imgProfileReceiver,
    String? userNameReceiver) async {
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  );
  final _donatePoint = TextEditingController();
  String? _tokenJwt = await tokenStore.getToken();

  _tokenJwt = "Bearer " + _tokenJwt!;
  print("_tokenJwt : ${_tokenJwt}");
  var url = Uri.parse('${ConfigApp.apiUserFindById}');
  var response = await http.post(url, headers: {
    "Accept": "application/json",
    "content-type": "application/json",
    "Authorization": "${_tokenJwt}"
  });
  if (response.statusCode == 200) {
    Map resMap = jsonDecode(response.body);
    userDataModel user = userDataModel.fromJson(resMap["data"]);
    print("resMap DATA  : ${resMap["data"]}");
    print("user token : ${user.token}");
    //TODO : เขียนเช็คถ้า userId คนรับคนส่งเป็นคนเดียวกันให้ Get.back
    Get.bottomSheet(
      Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(
                "Donate",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Text("${contentCaption}"),
            Column(
              children: <Widget>[
                Row(
                  children: [
                    Column(
                      children: [
                        buildImageProfileDonateSheet('$imgProfileReceiver'),
                        Text("$userNameReceiver")
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Icon(FontAwesomeIcons.arrowRightToBracket),
                    ),
                    Column(
                      children: [
                        buildImageProfileDonateSheet('${user.profilePic}'),
                        Text("${user.userName}"),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TextFormField(
                    cursorColor: Color(ConfigApp.cursorColor),
                    decoration: const InputDecoration(
                        icon: Icon(
                          FontAwesomeIcons.btc,
                          color: Color(ConfigApp.iconEmail),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                                color: Color(ConfigApp.buttonSecondary))),
                        label: Text("Token Donate")),
                    keyboardType: TextInputType.number,
                    controller: _donatePoint,
                    validator: (input) {
                      if (input!.isEmpty) {
                        return "plass enter Email";
                      } else {
                        return null;
                      }
                    },
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(300, 50),
                    primary: Color(ConfigApp.buttonSecondary),
                    elevation: 5,
                    shape: shape,
                    //side: BorderSide(width: 1,color: Color(Config.textColor),)
                  ),
                  onPressed: () {
                    tranferToken(contentId, _donatePoint.text, userIdReceiver);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.btc),
                      Text(
                        "Confirm",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(ConfigApp.buttonPrimary),
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
      elevation: 20,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
    );
  }
}