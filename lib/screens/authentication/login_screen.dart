import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:school_teacher/initities/read_device_data.dart';
import 'package:school_teacher/screens/dashboard.dart';
import 'package:school_teacher/screens/navigation/home_screen.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';
import 'package:school_teacher/widgets/cust_circular_progress_indicator.dart';

import '../../initities/colors.dart';
import '../../initities/consts.dart';
import '../../initities/handle_http_error.dart';
import '../../initities/urls.dart';
import '../../model/teacher.dart';




class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileTxtController = TextEditingController();
  final FocusNode _mobileFocusNode =  FocusNode();
  final FocusNode _passFocusNode =  FocusNode();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false;
  bool isChecked = false;
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration){
      init();
    });
    init();
  }

  init()async{
    if(Platform.isAndroid){
      _deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    }else if(Platform.isIOS){
      _deviceData = readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
    if(Pref.instance.containsKey('remember_me')){
      List<String> values = Pref.instance.getStringList('remember_me')??[];
      if(values.isNotEmpty){
        setState(() {
          isChecked = true;
          _mobileTxtController.text = values[0];
          _passwordTextController.text = values[1];
        });
      }
    }
    print(_deviceData.toString());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: screenWidth * 0.9,
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.05),
                            child: Image.asset(
                              'assets/icons/hello_bro.webp',
                              fit: BoxFit.cover,
                              width: screenWidth * 0.7,
                            ),
                          ),
                          Positioned(
                            bottom: (screenWidth * 0.7) * 0.12,
                            child: Text('Hello !!',style: TextStyle(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                            ),),
                          )
                        ]
                    ),
                  ),

                  // Title
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Subtitle
                  Text(
                    'Hello, there login to continue',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Employee Mobile Input
                  InputField(
                    controller: _mobileTxtController,
                    placeholder: 'Mobile No',
                    icon: Icons.phone_android_rounded,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    textInputType: TextInputType.number,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Password Input
                  InputField(
                    controller: _passwordTextController,
                    placeholder: 'Password',
                    icon: Icons.lock,
                    suffixIcon: Icons.visibility_off,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Remember Me and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            activeColor: CustColors.dark_sky,
                            value: isChecked,
                            onChanged: onChanged,
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forget Password?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Color(0xFFb5651d),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Login Button
                  Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    height: screenHeight * 0.06,
                    child: _isLoading ? Center(child: CustCircularProgress()):
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustColors.dark_sky,
                        foregroundColor: CustColors.white,
                        iconColor: CustColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular((screenHeight * 0.06)*0.9),
                        ),
                        padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.06)*0.02),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      onPressed: _login,
                      icon: Icon(Icons.login,size: (screenHeight * 0.06) * 0.4),
                      label: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: (screenHeight * 0.06) * 0.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // on login button click
  void _login() async {
    final String mobileTxt = _mobileTxtController.text.trim();
    final String passwordTxt = _passwordTextController.text.trim();
    final List<ConnectivityResult> connectivityResult =
    await Connectivity().checkConnectivity();

    if (mobileTxt.isEmpty) {
      _mobileFocusNode.requestFocus();
      return;
    }else if(mobileTxt.length < 10){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('please enter vaild mobile no'),
      ));
      return;
    }
    if (passwordTxt.isEmpty) {
      _passFocusNode.requestFocus();
      return;
    }

    if(isChecked){
      onChanged(isChecked);
    }

    if (!(connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No Connections'),
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.https(Urls.baseUrls, Urls.staffLogin);
      var body = json.encode({
        'mobileNumber': mobileTxt,
        'password': passwordTxt,
        // 'deviceId': Platform.isAndroid ? _deviceData['id']:_deviceData['identifierForVendor'],
      });

      var response = await post(uri, body: body, headers: {
        'Content-Type': 'application/json',
      });

      var rawData = json.decode(response.body);
      print(rawData);
      if (response.statusCode == 200) {
        Pref.instance.setBool(Consts.isLogin, true);
        Pref.instance.setString(
            Consts.teacherToken, rawData['data']['user'][Consts.teacherToken]);
        getUserDetailsFromAPI();
        Pref.instance.setString(
            Consts.organisationId, rawData['data']['user'][Consts.organisationId].toString());
        Pref.instance.setString(
            Consts.teacherCode, rawData['data']['user'][Consts.teacherCode]);
        Pref.instance.setString(
            Consts.organisationCode, rawData['data']['user'][Consts.organisationCode].toString());
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
      } else if (response.statusCode == 400) {
        var rawData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(rawData['message'] ?? 'Bad request, please try again.'),
        ));
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unauthorized access, please login again.'),
        ));
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Forbidden, you do not have permission to access this resource.'),
        ));
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Requested resource not found.'),
        ));
      } else if (response.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Internal Server Error, please try again later.'),
        ));
      } else if (response.statusCode == 503) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Service Unavailable, please try again later.'),
        ));
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Client Error: ${response.statusCode}. Please check your request.'),
        ));
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Server Error: ${response.statusCode}. Please try again later.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected error: ${response.statusCode}. Please try again.'),
        ));
      }
    } catch (exception, trace) {
      print('Exception: $exception, Trace: $trace');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network or server error, please check your connection.'),
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getUserDetailsFromAPI() async{
    final connectionResult = await Connectivity().checkConnectivity();
    if (!(connectionResult.contains(ConnectivityResult.mobile) ||
        connectionResult.contains(ConnectivityResult.wifi) ||
        connectionResult.contains(ConnectivityResult.ethernet))) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No internet connection')));
      return Future.error({
        'title': 'No connection',
        'desc': 'Please check your internet connectivity and try again.',
      });
    }

    try {
      if (Pref.instance.containsKey(Consts.teacherToken)) {
        final token = Pref.instance.getString(Consts.teacherToken) ?? '';
        Uri uri = Uri.https(Urls.baseUrls, Urls.staffProfile);

        final response = await get(uri,headers: {
          Consts.authorization: 'Bearer $token',
          Consts.content_type: 'application/json',
        });

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body[Consts.status] == 'Success') {
            var body = json.decode(response.body);
            print(body['profile'][0].toString());
            setState(() {
              Pref.instance.setString(Consts.userProfile, jsonEncode(body['profile'][0]));
              Teacher.fromJson(body['profile'][0] as Map<String,dynamic>);
            });
          } else {
            print(
                'Something went wrong !! Please retry after sometime');
          }
        }else {
          handleHttpError(context, response);
        }
      }
    } catch (exception) {
      print('Exception: $exception');
    }
  }

  void onChanged(bool? value) {
    if(value != null){
      isChecked = value;
      if(isChecked){
        setState(() {
          Pref.instance.setStringList('remember_me', [_mobileTxtController.text, _passwordTextController.text]);
        });
      } else {
        setState(() {
          Pref.instance.remove('remember_me');
        });
      }
    }
  }
}



class InputField extends StatefulWidget {
  final String placeholder;
  final IconData icon;
  TextEditingController controller;
  bool isPassword;
  FocusNode? focusNode;
  int? maxLength;
  TextInputType? textInputType;
  final IconData? suffixIcon;
  TextInputAction? textInputAction;
  bool obscureText = false;
  InputField({
    required this.placeholder,
    required this.icon,
    this.isPassword = false,
    this.suffixIcon,
    this.focusNode,
    required this.controller,
    this.maxLength,
    this.textInputType = TextInputType.text,
    required this.textInputAction
  }) {
    obscureText = this.isPassword;
  }

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return TextFormField(
      obscureText: widget.obscureText,
      focusNode: widget.focusNode,
      controller: widget.controller,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      keyboardType: widget.textInputType,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: (screenWidth * 0.045)),
      decoration: InputDecoration(
          counterText: '',
          labelText: widget.placeholder,
          labelStyle: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth * 0.04
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.04),vertical: screenWidth >= 375 ? screenWidth * 0.04:0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey),
          ),
          prefixIcon: Icon(widget.icon, color: Colors.black,size: (screenWidth * 0.04)*1.5,),
          suffixIcon: widget.isPassword ? IconButton(
            onPressed: () {
              setState(() {
                widget.obscureText = !widget.obscureText;
              });
            },
            icon: Icon(widget.obscureText ? Icons.visibility_off : Icons.visibility_rounded,color: Colors.black,size: (screenWidth * 0.04)*1.5,),
          ) : null
      ),
    );
  }
}