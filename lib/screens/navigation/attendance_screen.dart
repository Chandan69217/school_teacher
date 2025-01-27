import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:school_teacher/initities/urls.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';
import 'package:school_teacher/widgets/cust_circular_progress_indicator.dart';
import '../../initities/colors.dart';
import '../../initities/consts.dart';
import '../../initities/handle_http_error.dart';



class AttendanceScreen extends StatefulWidget {
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance'),titleSpacing: 0,foregroundColor: CustColors.white,backgroundColor: CustColors.dark_sky,),
      backgroundColor: CustColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Date'),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    value: 'Today', // Default value
                    items: ['Today', 'This Week', 'This Month']
                        .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        // Handle the selection and filter
                        // You can store the selected value and use it for fetching data
                      });
                    },
                  ),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    // Trigger search with the selected filter value
                    // You might want to re-fetch data based on selected value
                    setState(() {
                      // Update the filter or trigger a new fetch
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11.0),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getAttendance(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    return data!.isEmpty
                        ? Center(child: Text('No Data'))
                        : ListView.builder(
                      itemCount: data.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return attendanceCard(data:data[index]); // Pass data to card
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red,size: 50,),
                          SizedBox(height: 5,),
                          Text('Failed to load data: ${snapshot.error}'),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustColors.dark_sky,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                            ),
                            onPressed: () {
                              setState(() {});
                            },
                            child: Text('Retry'),
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
          ],
        ),
      ),
    );
  }


  Future<List<Map<String, dynamic>>> _getAttendance() async {
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
            return _handleError('Something went wrong !!', 'Please retry after sometime');
          }
        } else {
          return handleHttpError(context,response);
        }
      } else {
        print('User Token Not Available');
        return _handleError('Token Missing', 'Please log in again');
      }
    } catch (exception) {
      print('Exception: $exception');
      return _handleError('Something went wrong !!', 'Please retry after sometime');
    }
  }

  Future<List<Map<String, dynamic>>> _handleError(String title, String desc) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(desc)));
    return Future.error({
      'title': title,
      'desc': desc,
    });
  }



}






// class AttendanceScreen extends StatefulWidget {
//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }
//
// class _AttendanceScreenState extends State<AttendanceScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: CustColors.background,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Filter Date'),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                     ),
//                     value: 'Today', // Default value
//                     items: ['Today', 'This Week', 'This Month']
//                         .map((e) => DropdownMenuItem<String>(
//                       value: e,
//                       child: Text(e),
//                     ))
//                         .toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         // Handle the selection and filter
//                         // You can store the selected value and use it for fetching data
//                       });
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 10.0),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Trigger search with the selected filter value
//                     // You might want to re-fetch data based on selected value
//                     setState(() {
//                       // Update the filter or trigger a new fetch
//                     });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.indigoAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 11.0),
//                     child: Icon(Icons.search, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20.0),
//             Expanded(
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                 future: _getAttendance(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     var data = snapshot.data;
//                     return data!.isEmpty
//                         ? Center(child: Text('No Data'))
//                         : ListView.builder(
//                           itemCount: data.length,
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             return _attendanceCard(data:data[index]); // Pass data to card
//                           },
//                         );
//                   } else if (snapshot.hasError) {
//                     return Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red,size: 50,),
//                           SizedBox(height: 5,),
//                           Text('Failed to load data: ${snapshot.error}'),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: CustColors.dark_sky,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5.0),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 20.0,
//                                 vertical: 10.0,
//                               ),
//                             ),
//                             onPressed: () {
//                               setState(() {});
//                             },
//                             child: Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return Center(child: CustCircularProgress());
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Future<List<Map<String, dynamic>>> _getAttendance() async {
//     final connectionResult = await Connectivity().checkConnectivity();
//     if (!(connectionResult.contains(ConnectivityResult.mobile) ||
//         connectionResult.contains(ConnectivityResult.wifi) ||
//         connectionResult.contains(ConnectivityResult.ethernet))) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No internet connection')));
//       return Future.error({
//         'title': 'No connection',
//         'desc': 'Please check your internet connectivity and try again.',
//       });
//     }
//
//     try {
//       if (Pref.instance.containsKey(Consts.teacherToken)) {
//         final token = Pref.instance.getString(Consts.teacherToken) ?? '';
//         Uri uri = Uri.https(Urls.baseUrls, Urls.staffAttendanceList);
//
//         final response = await get(uri, headers: {
//           Consts.authorization: 'Bearer $token',
//           Consts.content_type: 'application/json',
//         });
//
//         if (response.statusCode == 200) {
//           final body = jsonDecode(response.body);
//           print(body.toString());
//
//           if (body[Consts.status] == 'Success') {
//             var result = List<Map<String, dynamic>>.from(
//               body['attendance'].map((e) => Map<String, dynamic>.from(e)),
//             );
//             return result;
//           } else {
//             return _handleError('Something went wrong !!', 'Please retry after sometime');
//           }
//         } else {
//           return handleHttpError(context,response);
//         }
//       } else {
//         print('User Token Not Available');
//         return _handleError('Token Missing', 'Please log in again');
//       }
//     } catch (exception) {
//       print('Exception: $exception');
//       return _handleError('Something went wrong !!', 'Please retry after sometime');
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> _handleError(String title, String desc) async {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(desc)));
//     return Future.error({
//       'title': title,
//       'desc': desc,
//     });
//   }
//
//
//
// }

class attendanceCard extends StatelessWidget{
  Map<String,dynamic> data;
  DateFormat dateTimeFormat = DateFormat('dd-MMM-yyyy h:mm:s a');
  DateFormat timeFormat = DateFormat('h:mm a');
  late String attendanceDate;
  late String checkInTime;
  late String checkOutTime;
  late String totalTime;
  late double latitude;
  late double longitude;
  attendanceCard({required this.data}){
    attendanceDate = data['attendanceDate'].toString().isEmpty?'N/A':data['attendanceDate'];
    checkInTime = data['inTime'].toString().isEmpty?'N/A':data['inTime'];
    checkOutTime = data['outTime'].toString().isEmpty?'N/A':data['outTime'];
    if(data['inTime'].toString().isNotEmpty && data['outTime'].toString().isNotEmpty){
      totalTime = findTimeDifference(timeFormat.parse(data['inTime']),timeFormat.parse(data['outTime']));
    }else{
      totalTime = 'N/A';
    }
  }


  String findTimeDifference(DateTime inTime, DateTime outTime) {
    Duration difference = outTime.difference(inTime);
    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60; // Get the remainder of minutes after hours
    return '$hours hours and $minutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustColors.background,
      elevation: 3,
      child: CustomPaint(
        painter: _RectPainter(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
      
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( attendanceDate,
                //'24-Jan-2025 11:06:50 AM',
                style: TextStyle(fontSize: 12.0, color: Colors.black54),
              ),
              SizedBox(height: 10.0),
              Text(
                'Total Time: $totalTime',
                style: TextStyle(fontSize: 12.0, color: Colors.black54),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Check In: ${checkInTime}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Check Out: ${checkOutTime}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }

}

  class _RectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
  Paint paint = Paint()
  ..color = CustColors.dark_sky
  .. style = PaintingStyle.fill;

  RRect rRect = RRect.fromLTRBAndCorners(
  0, 10, size.height * 0.1, size.height - 10,
  topRight: Radius.circular(10), // Round the top-right corner
  bottomRight: Radius.circular(10), // Round the bottom-right corner
  topLeft: Radius.zero, // No rounding for top-left corner
  bottomLeft: Radius.zero, // No rounding for bottom-left corner
  );
  canvas.drawRRect(rRect, paint);

  // canvas.clipRRect(RRect.fromRectAndRadius(
  //     Rect.fromPoints(
  //         Offset.zero,
  //         Offset(
  //           0,
  //           size.height,
  //         )),
  //     Radius.circular(10),));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
  return false;
  }
  }