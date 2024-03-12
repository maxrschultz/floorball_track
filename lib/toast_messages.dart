
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


void showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 20
  );
}