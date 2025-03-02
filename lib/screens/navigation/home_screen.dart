import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_teacher/initities/permission_handler.dart';
import 'package:school_teacher/model/teacher.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';
import '../../initities/colors.dart';
import '../../initities/consts.dart';
import '../../initities/handle_http_error.dart';
import '../../initities/urls.dart';
import '../../widgets/cust_circular_progress_indicator.dart';
import '../authentication/login_screen.dart';
import 'attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = ValueNotifier<bool>(false);
  bool _punchBtnLoading = false;
  bool _switchValue = false;
  String inTime = 'N/A';
  String outTime = 'N/A';
  DateFormat dateFormat = DateFormat('dd-MMM-yyyy h:mm a');
  DateFormat inputFormat = DateFormat("dd/MM/yyyy hh:mm a");
  DateFormat dateFormat1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");



  _markAttendance(bool? value) async {
    setState(() {
      _punchBtnLoading = true;
    });
    var status = await getLocationPermission();
    if (status == LocationPermissionStatus.granted) {
      var position = await Geolocator.getCurrentPosition();
      if (position.isMocked) {
        showDialog(
            dialogType: DialogType.warning,
            title: 'Mocked Location',
            desc: 'please turn of mock and try again');
        return _handleError('Mocked location', 'please turn it off');
      }
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
          Uri uri = Uri.https(Urls.baseUrls, Urls.staffAttendance);
          var body = json.encode({
            "latitude": position.latitude.toString(),
            "longitude": position.longitude.toString(),
            "attendanceTime": dateFormat1.format(DateTime.now()),
            "staffStatus": !_switchValue ? 'IN' : 'OUT'
          });

          final response = await post(uri, body: body, headers: {
            Consts.authorization: 'Bearer $token',
            Consts.content_type: 'application/json',
          });

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            print(body.toString());
            if (body[Consts.status] == 'success') {
              setState(() {
                _punchBtnLoading = false;
                _switchValue = value ?? false;
              });
              showDialog(
                  dialogType: DialogType.success,
                  title: 'Success',
                  desc:
                  '${!_switchValue ? 'Punch Out' : 'Punch In'} successfully');
              if(body['response']['status'].toString().toLowerCase() == 'in'){
                inTime =
                    dateFormat.format(DateTime.parse(body['response']['staffAttendanceTime']));
              }else{
                outTime = dateFormat
                    .format(DateTime.parse(body['response']['staffAttendanceTime']));
              }
            } else {
              setState(() {
                _punchBtnLoading = false;
              });
              return _handleError(
                  'Something went wrong !!', 'Please retry after sometime');
            }
          } else if(response.statusCode == 400){
            showDialog(
                dialogType: DialogType.warning,
                title: 'Warning',
                desc: json.decode(response.body)['message']);
          }else {
            setState(() {
              _punchBtnLoading = false;
            });
            return handleHttpError(context, response);
          }
        } else {
          setState(() {
            _punchBtnLoading = false;
          });
          print('User Token Not Available');
          return _handleError('Token Missing', 'Please log in again');
        }
      } catch (exception) {
        setState(() {
          _punchBtnLoading = false;
        });
        print('Exception: $exception');
        return _handleError(
            'Something went wrong !!', 'Please retry after sometime');
      }
    } else if (status == LocationPermissionStatus.denied) {
      Permission.location.request();
    } else if (status == LocationPermissionStatus.serviceDisabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Turn on your location')));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Text('Location Permissin denied please allow'),
              TextButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  child: Text('open settings'))
            ],
          ),
        ));
      }
    }
    setState(() {
      _punchBtnLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _handleError(
      String title, String desc) async {
    double screenWidth = MediaQuery.of(context).size.width;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          desc,
          style: TextStyle(
              fontSize: screenWidth * 0.02,
              color: Colors.white,
              height: 0
          ),
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      ),
    );
    return Future.error({
      'title': title,
      'desc': desc,
    });
  }


  @override
  void initState() {
    super.initState();
    getUserDetailsFromAPI();
    _checkLastStatus();
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
            _handleError(
                'Something went wrong !!', 'Please retry after sometime');
          }
        }else {
          handleHttpError(context, response);
        }
      } else {
        print('User Token Not Available');
        _handleError('Token Missing', 'Please log in again');
      }
    } catch (exception) {
      print('Exception: $exception');
      _handleError(
          'Something went wrong !!', 'Please retry after sometime');
    }
  }

  Future<bool> _getUserDetailsFromCached() async{
    if(Pref.instance.containsKey(Consts.userProfile)){
      Teacher.fromJson(json.decode(Pref.instance.getString(Consts.userProfile)!) as Map<String,dynamic>);
      return true;
    }else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenWidth, screenHeight * 0.07),
        child: AppBar(
          title: Text('Dashboard',style: TextStyle(fontSize:  (screenHeight * 0.07) * 0.4),),
          titleSpacing: 0,
          backgroundColor: CustColors.dark_sky,
          foregroundColor: CustColors.white,
          leading: Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu, color: CustColors.white,size: (screenHeight * 0.07) * 0.5,))),
        ),
      ),
      backgroundColor: CustColors.background,
      body: FutureBuilder(future: _getUserDetailsFromCached(),
          builder:(context, snapshot){
            if(snapshot.hasData){
              return Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Profile Card
                  Container(
                    height: screenHeight * 0.18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00b894),
                          Color(0xFF008f99),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: CustColors.grey, blurRadius: 4, offset: Offset(0, 2))
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all((screenHeight * 0.18) * 0.07),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: (screenHeight * 0.18) * 0.2,
                              backgroundColor:  Colors.transparent,
                              child: ClipOval(
                                child: SizedBox.expand(
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/icons/dummy-profile-image.webp',
                                    image: Teacher.teacherImage,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/icons/dummy-profile-image.webp',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: (screenHeight * 0.18) * 0.05),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Teacher.teacherName.isEmpty?'N/A':Teacher.teacherName,
                                      style: TextStyle(
                                          fontSize: (screenHeight * 0.18) * 0.11,
                                          fontWeight: FontWeight.bold,
                                          height: 0,
                                          color: Colors.white)),
                                  Text(Teacher.teacherDepartment.isEmpty?'N/A':Teacher.teacherDepartment,
                                      style:
                                      TextStyle(fontSize: (screenHeight * 0.18) * 0.09, color: Colors.white,height: 0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: (screenHeight * 0.18) * 0.05),
                                Text('Shift: ${Teacher.teacherType}',
                                    style:
                                    TextStyle(fontSize: (screenHeight * 0.18) * 0.1, color: Colors.white)),
                                Text('In: $inTime',
                                    style:
                                    TextStyle(fontSize: (screenHeight * 0.18) * 0.1, color: Colors.white,height: 0)),
                                Text('Out: $outTime',
                                    style:
                                    TextStyle(fontSize: (screenHeight * 0.18) * 0.1, color: Colors.white,height: 0)),
                              ],
                            ),
                            Spacer(),
                            if (_punchBtnLoading)
                              Expanded(
                                  child: Center(
                                      child: CustCircularProgress(
                                        color: Colors.white,
                                        size: (screenHeight * 0.18) * 0.05,
                                      )))
                            else
                              FlutterSwitch(
                                width: screenWidth * 0.37,
                                height: screenWidth * 0.1,
                                borderRadius: 30.0,
                                showOnOff: true,
                                activeTextColor: CustColors.white,
                                inactiveTextColor: CustColors.white,
                                padding: (screenWidth * 0.37)*0.06,
                                activeText: 'Out',
                                inactiveText: 'In',
                                inactiveColor: Colors.green,
                                activeColor: Colors.red,
                                activeTextFontWeight: FontWeight.normal,
                                inactiveTextFontWeight: FontWeight.normal,
                                valueFontSize: (screenWidth * 0.37)*0.12,
                                activeIcon: Icon(Icons.arrow_back_rounded),
                                inactiveIcon: Icon(Icons.arrow_forward_rounded),
                                onToggle: _markAttendance, value: _switchValue,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025, horizontal: screenWidth * 0.02),
                    child: Text('Recent Activity',
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: CustColors.dark_grey)),
                  ),

                  // Attendance list
                  Expanded(
                    flex: 4,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getAttendance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data;
                          if (data!.isEmpty) {
                            return Center(child: Text('No Data',style: TextStyle(fontSize: screenWidth * 0.04),));
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: data.length > 10 ? 11: data.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      if (index == 10) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                          child: ElevatedButton(
                                            onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AttendanceScreen()));},
                                            style: ElevatedButton.styleFrom(backgroundColor: CustColors.dark_sky,foregroundColor: CustColors.white),
                                            child: Text('See More',style: TextStyle(fontSize: (screenHeight * 0.02)),),
                                          ),
                                        );
                                      } else
                                        return attendanceCard(data: data[index]);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.triangleExclamation,
                                  color: Colors.red,
                                  size: screenWidth * 0.1,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Failed to load data\n ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: screenWidth * 0.04),
                                ),
                                SizedBox(height: 5,),
                                SizedBox(
                                  height: screenWidth * 0.09,
                                  width: screenWidth * 0.35,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustColors.dark_sky,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: (screenWidth * 0.09) * 0.01,
                                        vertical: (screenWidth * 0.09) * 0.02,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    child: Text('Retry',style: TextStyle(fontSize: (screenWidth * 0.09)*0.4),),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(child: CustCircularProgress());
                        }
                      },
                    ),
                  ),
                ]),
              );
            } else if(snapshot.hasError){
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.triangleExclamation,
                      color: Colors.red,
                      size: screenWidth * 0.1,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Failed to load data\n ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      height: screenWidth * 0.09,
                      width: screenWidth * 0.35,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustColors.dark_sky,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: (screenWidth * 0.09) * 0.01,
                            vertical: (screenWidth * 0.09) * 0.02,
                          ),
                        ),
                        onPressed: () {
                          setState(() {});
                        },
                        child: Text('Retry',style: TextStyle(fontSize: (screenWidth * 0.09)*0.4),),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: CustCircularProgress());
            }
          }),
      drawer: _drawerUI(),
    );
  }


  Future<List<Map<String, dynamic>>> _getAttendance() async {
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
        Uri uri = Uri.https(Urls.baseUrls, Urls.staffAttendanceList);

        final response = await get(uri, headers: {
          Consts.authorization: 'Bearer $token',
          Consts.content_type: 'application/json',
        });

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          print(body.toString());

          if (body[Consts.status] == 'Success') {
            var result = List<Map<String, dynamic>>.from(
              body['attendance'].map((e) => Map<String, dynamic>.from(e)),
            );
            return result;
          } else {
            return _handleError(
                'Something went wrong !!', 'Please retry after sometime');
          }
        } else {
          return handleHttpError(context, response);
        }
      } else {
        print('User Token Not Available');
        return _handleError('Token Missing', 'Please log in again');
      }
    } catch (exception) {
      print('Exception: $exception');
      return _handleError(
          'Something went wrong !!', 'Please retry after sometime');
    }
  }

  Widget _buildInfoRow(String title, String value) {
    double screenWidth = MediaQuery.of(context).size.width * 0.8;
    double screenHeight = MediaQuery.of(context).size.height * 0.69;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: CustColors.grey,
              fontSize: screenWidth * 0.04,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: CustColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          Divider(
            color: CustColors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }


  void showDialog({
    String? title,
    String? desc,
    required DialogType dialogType,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    AwesomeDialog(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      context: context,
      title: title,
      titleTextStyle: TextStyle(
          fontSize:  screenWidth * 0.05
      ),
      desc: desc,
      descTextStyle: TextStyle(
        fontSize: screenWidth * 0.035,
      ),
      dialogType: dialogType,
      btnOkOnPress: () {},
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      animType: AnimType.bottomSlide,
      btnOkText: 'OK',
      dialogBorderRadius: BorderRadius.circular(10),
      dialogBackgroundColor: Colors.white,
      width: screenWidth,
    ).show();
  }


  Widget _drawerUI() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double drawerWidth = screenWidth * 0.8;
    return Drawer(
      backgroundColor: CustColors.dark_sky,
      width: drawerWidth,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.31,
              padding: EdgeInsets.symmetric(horizontal: (screenHeight * 0.31)* 0.05),
              decoration: BoxDecoration(
                color: CustColors.dark_sky,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: drawerWidth,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 2, color: CustColors.white),
                            ),
                            child: CircleAvatar(
                              radius: (screenHeight * 0.31) * 0.25,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: SizedBox.expand(
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/icons/dummy-profile-image.webp',
                                    image: Teacher.teacherImage,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/icons/dummy-profile-image.webp',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: (screenHeight * 0.31) * 0.02),
                          Text(
                            Teacher.teacherName.isEmpty ? 'N/A' : Teacher.teacherName,
                            style: TextStyle(
                                fontSize: (screenHeight * 0.31) * 0.09,
                                color: CustColors.white,
                                fontWeight: FontWeight.bold,
                                height: 0
                            ),
                          ),
                          Text(
                            Teacher.teacherMobileNumber.isEmpty ? 'N/A' : '+91 ${Teacher.teacherMobileNumber}',
                            style: TextStyle(
                                color: CustColors.background,
                                fontSize: (screenHeight * 0.31) * 0.049,
                                height: 0
                            ),
                          ),
                          SizedBox(height: (screenHeight * 0.31) * 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              height: screenHeight * 0.69,
              padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.69) * 0.02, horizontal: drawerWidth * 0.05),
              decoration: BoxDecoration(color: CustColors.background),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Teacher ID', '${Teacher.teacherId}'),
                      _buildInfoRow('Email ID', '${Teacher.teacherEmailId}'),
                      _buildInfoRow('Designation', '${Teacher.teacherDesignation}'),
                      _buildInfoRow('Teacher Type', '${Teacher.teacherType}'),
                      _buildInfoRow('Department', '${Teacher.teacherDepartment}'),
                      _buildInfoRow('Gender', '${Teacher.teacherGender}'),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: drawerWidth * 0.6,
                        child: TextButton.icon(
                          icon: Icon(Icons.logout,color: Colors.red,size: drawerWidth * 0.065,),
                          onPressed: () {
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
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            textStyle: TextStyle(fontSize: (screenHeight * 0.69) * 0.03),
                            padding: EdgeInsets.symmetric(horizontal: (screenHeight * 0.69) * 0.04, vertical: screenHeight * 0.015),
                          ),
                          label: const Text('Logout'),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.69) * 0.02),
                      Text(
                        'Version 1.01.321',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: CustColors.grey,fontSize: drawerWidth * 0.05),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkLastStatus() async{
    final connectionResult = await Connectivity().checkConnectivity();
    if (!(connectionResult.contains(ConnectivityResult.mobile) ||
        connectionResult.contains(ConnectivityResult.wifi) ||
        connectionResult.contains(ConnectivityResult.ethernet))) {
      return;
    }

    try {
      if (Pref.instance.containsKey(Consts.teacherToken)) {
        final token = Pref.instance.getString(Consts.teacherToken) ?? '';
        Uri uri = Uri.https(Urls.baseUrls, Urls.lastAttendanceStatus);

        final response = await get(uri,headers: {
          Consts.authorization: 'Bearer $token',
          Consts.content_type: 'application/json',
        });

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body[Consts.status] == 'Success') {
            var body = json.decode(response.body) as Map<String,dynamic>;
            var status = body['data']['lastStatus'].toString().toUpperCase();
            var date = body['data']['attendanceDate'].toString();
            var punchInTime = body['data']['inTime'].toString();
            var punchOutTime = body['data']['outTime'].toString();
            setState(() {
              if(status == 'IN'){
                _switchValue = true;
              }
              else{
                _switchValue = false;
              }
              if(punchInTime.isNotEmpty){
                inTime = dateFormat.format(inputFormat.parse('$date $punchInTime'));
              }
              if(punchOutTime.isNotEmpty){
                outTime = dateFormat.format(inputFormat.parse('$date $punchOutTime'));
              }
            });
          } else {
            print('Something went wrong !! with status code : ${response.statusCode}');
            return;
          }
        }else {
          print('Something went wrong !! with status code : ${response.statusCode}');
          return;
        }
      } else {
        print('User Token Not Available');
        return;
      }
    } catch (exception) {
      print('Exception: $exception');
    }
  }

}






// class HomeScreen extends StatefulWidget {
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final _controller = ValueNotifier<bool>(false);
//   bool _punchBtnLoading = false;
//   bool _switchValue = false;
//   String inTime = 'N/A';
//   String outTime = 'N/A';
//   DateFormat dateFormat = DateFormat('dd-MMM-yyyy h:mm:ss a');
//   DateFormat dateFormat1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
//
//   _markAttendance(bool? value)async{
//     setState(() {
//       _punchBtnLoading = true;
//     });
//     var status = await getLocationPermission();
//     if(status == LocationPermissionStatus.granted){
//       var position = await Geolocator.getCurrentPosition();
//       if(position.isMocked){
//         showDialog(dialogType: DialogType.warning,title: 'Mocked Location',desc: 'please turn of mock and try again');
//         return _handleError('Mocked location', 'please turn it off');
//       }
//       final connectionResult = await Connectivity().checkConnectivity();
//       if (!(connectionResult.contains(ConnectivityResult.mobile) ||
//           connectionResult.contains(ConnectivityResult.wifi) ||
//           connectionResult.contains(ConnectivityResult.ethernet))) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No internet connection')));
//         return Future.error({
//           'title': 'No connection',
//           'desc': 'Please check your internet connectivity and try again.',
//         });
//       }
//
//       try {
//         if (Pref.instance.containsKey(Consts.teacherToken)) {
//           final token = Pref.instance.getString(Consts.teacherToken) ?? '';
//           Uri uri = Uri.https(Urls.baseUrls, Urls.staffAttendance);
//           var body = json.encode({
//               "latitude": position.latitude.toString(),
//               "longitude": position.longitude.toString(),
//               "staffInTime": dateFormat1.format(DateTime.now()),
//               "staffOutTime": dateFormat1.format(DateTime.now()),
//               "staffStatus": _switchValue ? 'IN':'OUT'
//           });
//
//           final response = await post(uri,body: body ,headers: {
//             Consts.authorization: 'Bearer $token',
//             Consts.content_type: 'application/json',
//           });
//
//           if (response.statusCode == 200) {
//             final body = jsonDecode(response.body);
//             print(body.toString());
//             if (body[Consts.status] == 'success') {
//               setState(() {
//                 _punchBtnLoading = false;
//               });
//               showDialog(dialogType: DialogType.success,title: 'Success',desc: '${_switchValue?'Punch Out':'Punch In'} successfully');
//               inTime = dateFormat.format(DateTime.parse(body['response']['inTime']));
//               outTime = dateFormat.format(DateTime.parse(body['response']['outTime']));
//               setState(() {
//                 _switchValue = value??false;
//               });
//             } else {
//               setState(() {
//                 _punchBtnLoading = false;
//               });
//               return _handleError('Something went wrong !!', 'Please retry after sometime');
//             }
//           } else {
//             setState(() {
//               _punchBtnLoading = false;
//             });
//             return handleHttpError(context,response);
//           }
//         } else {
//           setState(() {
//             _punchBtnLoading = false;
//           });
//           print('User Token Not Available');
//           return _handleError('Token Missing', 'Please log in again');
//         }
//       } catch (exception) {
//         setState(() {
//           _punchBtnLoading = false;
//         });
//         print('Exception: $exception');
//         return _handleError('Something went wrong !!', 'Please retry after sometime');
//       }
//     }else if(status == LocationPermissionStatus.denied){
//       Permission.location.request();
//     }else if(status == LocationPermissionStatus.serviceDisabled){
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Turn on your location')));
//     }else{
//       if(mounted){
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Text('Location Permissin denied please allow'),TextButton(onPressed: (){openAppSettings();}, child: Text('open settings'))],),));
//       }
//     }
//     setState(() {
//       _punchBtnLoading = false;
//     });
//   }
//
//   Future<List<Map<String, dynamic>>> _handleError(String title, String desc) async {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(desc)));
//     return Future.error({
//       'title': title,
//       'desc': desc,
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: CustColors.background,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profile Card
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF00b894),Color(0xFF008f99),],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   boxShadow: [BoxShadow(
//                     color: CustColors.grey,
//                     blurRadius: 4,
//                     offset: Offset(0, 2)
//                   )],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundImage: NetworkImage(
//                             'https://storage.googleapis.com/a1aa/image/X4g9mngEvb46AdEvMyivVsXH5YVtIIoHveo4bu2qx3p73GEKA.jpg'),
//                         radius: 30,
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('PRABHAT RAJ',
//                                 style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white)),
//                             Text('Web Developer',
//                                 style: TextStyle(
//                                     fontSize: 12, color: Colors.white)),
//
//                           ],
//                         ),
//                       ),
//                     ],
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 5),
//                           Text('Shift: GENERAL',
//                               style: TextStyle(
//                                   fontSize: 14, color: Colors.white)),
//                           Text('In: $inTime',
//                               style: TextStyle(
//                                   fontSize: 14, color: Colors.white)),
//                           Text('Out: $outTime',
//                               style: TextStyle(
//                                   fontSize: 14, color: Colors.white)),
//                         ],
//                       ),
//                       Spacer(),
//                       if (_punchBtnLoading) Expanded(child: Center(child: CustCircularProgress(color: Colors.white,))) else FlutterSwitch(
//                           width: 120.0,
//                           height: 40,
//                           //value: lastStatus == 'IN' ? true:false,
//                           borderRadius: 30.0,
//                           showOnOff: true,
//                           activeTextColor: CustColors.white,
//                           inactiveTextColor: CustColors.white,
//                           padding: 8.0,
//                           activeText: 'Out',
//                           inactiveText: 'In',
//                           inactiveColor: Colors.green,
//                           activeColor: Colors.red,
//                           activeTextFontWeight: FontWeight.normal,
//                           inactiveTextFontWeight: FontWeight.normal,
//                           valueFontSize: 18.0,
//                           activeIcon: Icon(Icons.arrow_back_rounded),
//                           inactiveIcon: Icon(Icons.arrow_forward_rounded),
//                           onToggle: _markAttendance, value: _switchValue,
//                       ),
//                     ],
//                   ),],),),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 10.0),
//                 child: Text('Menu',
//                     style: TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold,color: CustColors.dark_grey)),
//               ),
//               GridView.count(
//                 shrinkWrap: true,
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 30,
//                 crossAxisSpacing: 30,
//                 childAspectRatio: 1.5,
//                 physics: NeverScrollableScrollPhysics(),
//                 children: [
//                   MenuItem(
//                     icon: FontAwesomeIcons.userLarge,
//                     title: 'Profile',
//                   ),
//                   MenuItem(
//                     icon: FontAwesomeIcons.userCheck,
//                     title: 'Attendance',
//                   ),
//                   MenuItem(
//                     icon:FontAwesomeIcons.personWalkingArrowRight,
//                     title: 'Leave',
//                   ),
//                   MenuItem(
//                     icon:FontAwesomeIcons.wallet,
//                     title: 'Payslip',
//                   ),
//                   MenuItem(
//                     icon:FontAwesomeIcons.handHoldingHand,
//                     title: 'Helpdesk',
//                   ),
//                   MenuItem(
//                     icon:FontAwesomeIcons.leaf,
//                     title: 'Regularization',
//                   ),
//                 ],
//               ),
//             ]
//           ),
//         )));
//   }
//
//   showDialog({String? title,String? desc,required DialogType dialogType,}){
//     AwesomeDialog(context: context,
//       title: title,
//       desc: desc,
//       dialogType: dialogType,
//       btnOkOnPress: (){},
//       dismissOnBackKeyPress: false,
//       dismissOnTouchOutside: false,
//       animType: AnimType.bottomSlide,
//     ).show();
//   }
// }

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  MenuItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 25,
          ),
          // Image.asset(icon,width: 25,height: 25,),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
              child: Text(
            title,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
          ))
        ],
      ),
    );
  }
}
