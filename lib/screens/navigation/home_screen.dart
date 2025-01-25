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
import 'package:school_teacher/screens/splash/splash_screen.dart';
import '../../initities/colors.dart';
import '../../initities/consts.dart';
import '../../initities/handle_http_error.dart';
import '../../initities/urls.dart';
import '../../widgets/cust_circular_progress_indicator.dart';



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
  DateFormat dateFormat = DateFormat('dd-MMM-yyyy h:mm:ss a');
  DateFormat dateFormat1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");

  _markAttendance(bool? value)async{
    setState(() {
      _punchBtnLoading = true;
    });
    var status = await getLocationPermission();
    if(status == LocationPermissionStatus.granted){
      var position = await Geolocator.getCurrentPosition();
      if(position.isMocked){
        showDialog(dialogType: DialogType.warning,title: 'Mocked Location',desc: 'please turn of mock and try again');
        return _handleError('Mocked location', 'please turn it off');
      }
      final connectionResult = await Connectivity().checkConnectivity();
      if (!(connectionResult.contains(ConnectivityResult.mobile) ||
          connectionResult.contains(ConnectivityResult.wifi) ||
          connectionResult.contains(ConnectivityResult.ethernet))) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No internet connection')));
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
              "staffInTime": dateFormat1.format(DateTime.now()),
              "staffOutTime": dateFormat1.format(DateTime.now()),
              "staffStatus": _switchValue ? 'IN':'OUT'
          });

          final response = await post(uri,body: body ,headers: {
            Consts.authorization: 'Bearer $token',
            Consts.content_type: 'application/json',
          });

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            print(body.toString());
            if (body[Consts.status] == 'success') {
              setState(() {
                _punchBtnLoading = false;
              });
              showDialog(dialogType: DialogType.success,title: 'Success',desc: '${_switchValue?'Punch Out':'Punch In'} successfully');
              inTime = dateFormat.format(DateTime.parse(body['response']['inTime']));
              outTime = dateFormat.format(DateTime.parse(body['response']['outTime']));
              setState(() {
                _switchValue = value??false;
              });
            } else {
              setState(() {
                _punchBtnLoading = false;
              });
              return _handleError('Something went wrong !!', 'Please retry after sometime');
            }
          } else {
            setState(() {
              _punchBtnLoading = false;
            });
            return handleHttpError(context,response);
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
        return _handleError('Something went wrong !!', 'Please retry after sometime');
      }
    }else if(status == LocationPermissionStatus.denied){
      Permission.location.request();
    }else if(status == LocationPermissionStatus.serviceDisabled){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Turn on your location')));
    }else{
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Text('Location Permissin denied please allow'),TextButton(onPressed: (){openAppSettings();}, child: Text('open settings'))],),));
      }
    }
    setState(() {
      _punchBtnLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _handleError(String title, String desc) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(desc)));
    return Future.error({
      'title': title,
      'desc': desc,
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CustColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00b894),Color(0xFF008f99),],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(
                    color: CustColors.grey,
                    blurRadius: 4,
                    offset: Offset(0, 2)
                  )],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://storage.googleapis.com/a1aa/image/X4g9mngEvb46AdEvMyivVsXH5YVtIIoHveo4bu2qx3p73GEKA.jpg'),
                        radius: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PRABHAT RAJ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text('Web Developer',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),

                          ],
                        ),
                      ),
                    ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text('Shift: GENERAL',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white)),
                          Text('In: $inTime',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white)),
                          Text('Out: $outTime',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white)),
                        ],
                      ),
                      Spacer(),
                      if (_punchBtnLoading) Expanded(child: Center(child: CustCircularProgress(color: Colors.white,))) else FlutterSwitch(
                          width: 120.0,
                          height: 40,
                          //value: lastStatus == 'IN' ? true:false,
                          borderRadius: 30.0,
                          showOnOff: true,
                          activeTextColor: CustColors.white,
                          inactiveTextColor: CustColors.white,
                          padding: 8.0,
                          activeText: 'Out',
                          inactiveText: 'In',
                          inactiveColor: Colors.green,
                          activeColor: Colors.red,
                          activeTextFontWeight: FontWeight.normal,
                          inactiveTextFontWeight: FontWeight.normal,
                          valueFontSize: 18.0,
                          activeIcon: Icon(Icons.arrow_back_rounded),
                          inactiveIcon: Icon(Icons.arrow_forward_rounded),
                          onToggle: _markAttendance, value: _switchValue,
                      ),
                    ],
                  ),],),),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 10.0),
                child: Text('Menu',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,color: CustColors.dark_grey)),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 30,
                crossAxisSpacing: 30,
                childAspectRatio: 1.5,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  MenuItem(
                    icon: FontAwesomeIcons.userLarge,
                    title: 'Profile',
                  ),
                  MenuItem(
                    icon: FontAwesomeIcons.userCheck,
                    title: 'Attendance',
                  ),
                  MenuItem(
                    icon:FontAwesomeIcons.personWalkingArrowRight,
                    title: 'Leave',
                  ),
                  MenuItem(
                    icon:FontAwesomeIcons.wallet,
                    title: 'Payslip',
                  ),
                  MenuItem(
                    icon:FontAwesomeIcons.handHoldingHand,
                    title: 'Helpdesk',
                  ),
                  MenuItem(
                    icon:FontAwesomeIcons.leaf,
                    title: 'Regularization',
                  ),
                ],
              ),
            ]
          ),
        )));
  }

  showDialog({String? title,String? desc,required DialogType dialogType,}){
    AwesomeDialog(context: context,
      title: title,
      desc: desc,
      dialogType: dialogType,
      btnOkOnPress: (){},
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      animType: AnimType.bottomSlide,
    ).show();
  }
}

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
          Icon(icon,size: 25,),
         // Image.asset(icon,width: 25,height: 25,),
          SizedBox(height: 5.0,),
          Expanded(child: Text(title,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),))
        ],
      ),
    );
  }
}