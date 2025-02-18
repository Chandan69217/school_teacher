import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../screens/authentication/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'consts.dart';

Future<List<Map<String, dynamic>>> handleHttpError(BuildContext context,Response response) async {
  String errorTitle = 'Error';
  String errorDesc = 'Please retry after sometime';

  switch (response.statusCode) {
    case 400:
      errorTitle = 'Bad Request';
      errorDesc = 'The request is invalid. Please check your data.';
      break;
    case 401:
      errorTitle = 'Unauthorized';
      errorDesc = 'Session expired or you are not authorized. Please log in again.';
      break;
    case 403:
      errorTitle = 'Forbidden';
      errorDesc = 'You do not have permission to access this resource.';
      break;
    case 404:
      errorTitle = 'Not Found';
      errorDesc = 'The requested resource could not be found.';
      break;
    case 500:
      errorTitle = 'Server Error';
      errorDesc = 'Something went wrong on the server. Please login again.';
      Pref.instance.remove(Consts.isLogin);
      Pref.instance.remove(Consts.teacherToken);
      Pref.instance.remove(Consts.organisationId);
      Pref.instance.remove(Consts.organisationCode);
      Pref.instance.remove(Consts.teacherCode);
      Pref.instance.remove(Consts.userProfile);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
      break;
    case 502:
      errorTitle = 'Bad Gateway';
      errorDesc = 'The server received an invalid response from an upstream server.';
      break;
    case 503:
      errorTitle = 'Service Unavailable';
      errorDesc = 'The server is temporarily unavailable. Please try again later.';
      break;
    default:
      errorDesc = 'An unexpected error occurred. Please try again later.';
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorDesc)));
  return Future.error({
    'title': errorTitle,
    'desc': errorDesc,
  });
}

