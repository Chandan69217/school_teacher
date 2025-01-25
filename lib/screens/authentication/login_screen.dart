import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:school_teacher/screens/dashboard.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';
import 'package:school_teacher/widgets/cust_circular_progress_indicator.dart';

import '../../initities/colors.dart';
import '../../initities/consts.dart';
import '../../initities/urls.dart';


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

  @override
  void initState() {
    super.initState();
    init();
  }

  init()async{
    if(Pref.instance.containsKey('remember_me')){
      List<String> values = Pref.instance.getStringList('remember_me')??[];
      if(values.isNotEmpty){
        isChecked = true;
        _mobileTxtController.text = values[0];
        _passwordTextController.text = values[1];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100,),
                  // Logo
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      margin: EdgeInsets.only(bottom: 20),
                      child: Image.asset(
                        'assets/icons/security-shield.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Subtitle
                  Text(
                    'Hello, there login to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Employee ID Input
                  InputField(
                    controller: _mobileTxtController,
                    placeholder: 'Mobile No',
                    icon: Icons.phone_android_rounded,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    textInputType: TextInputType.number,
                  ),

                  SizedBox(height: 15),

                  // Password Input
                  InputField(
                    controller: _passwordTextController,
                    placeholder: 'Password',
                    icon: Icons.lock,
                    suffixIcon: Icons.visibility_off,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: 15),

                  // Remember Me and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            activeColor: CustColors.dark_sky,
                            value: isChecked,
                            onChanged: onChanged
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forget Password?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFb5651d),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    height: 50,
                    child: _isLoading ? Center(child: CustCircularProgress()):
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustColors.dark_sky,
                        foregroundColor: CustColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      onPressed: _login,
                      icon: Icon(Icons.login),
                      label: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
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
      });

      var response = await post(uri, body: body, headers: {
        'Content-Type': 'application/json',
      });

      // Check status code
      if (response.statusCode == 200) {
        var rawData = json.decode(response.body);
        Pref.instance.setBool(Consts.isLogin, true);
        Pref.instance.setString(
            Consts.teacherToken, rawData['data']['user'][Consts.teacherToken]);
        Pref.instance.setString(
            Consts.organisationId, rawData['data']['user'][Consts.organisationId].toString());
        Pref.instance.setString(
            Consts.teacherCode, rawData['data']['user'][Consts.teacherCode]);
        Pref.instance.setString(
            Consts.organisationCode, rawData['data']['user'][Consts.organisationCode].toString());
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false,
        );
      } else if (response.statusCode == 400) {
        var rawData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(rawData['message'] ?? 'Bad request, please try again.'),
        ));
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  void onChanged(bool? value) {
    if(value!=null){
      isChecked = value;
      if(isChecked){
        setState(() {
          Pref.instance.setStringList('remember_me', [_mobileTxtController.text,_passwordTextController.text]);
        });
      }else{
        setState(() {
          Pref.instance.remove('remember_me',);
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
  InputField({super.key,
    required this.placeholder,
    required this.icon,
    this.isPassword = false,
    this.suffixIcon,
    this.focusNode,
    required this.controller,
    this.maxLength,
    this.textInputType = TextInputType.text,
    required this.textInputAction
  }){
    obscureText = this.isPassword;
  }

  @override
  State<InputField> createState() => _InputFieldState();
}
class _InputFieldState extends State<InputField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obscureText,
      focusNode: widget.focusNode,
      controller: widget.controller,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      keyboardType: widget.textInputType,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 18.0),
      decoration: InputDecoration(
        counterText: '',
        labelText: widget.placeholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.grey),
        ),
        prefixIcon: Icon(widget.icon,color: Colors.black,),
        suffixIcon: widget.isPassword ? IconButton(onPressed: (){setState(() {
          widget.obscureText = !widget.obscureText;
        });}, icon: Icon(widget.obscureText ? Icons.visibility_off : Icons.visibility_rounded)):null
      ),
    );
  }
}