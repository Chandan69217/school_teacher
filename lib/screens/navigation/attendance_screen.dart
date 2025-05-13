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
  String filterValue = 'All';
  Map<String, int>? attendanceCount;
  late Future<List<Map<String, dynamic>>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _getAttendance(filterValue);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: Navigator.of(context).canPop()? _buildAppBar(screenWidth, screenHeight):null,
      backgroundColor: CustColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterDropdown(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            Expanded(child: _buildAttendanceData(screenWidth, screenHeight)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth, double screenHeight) {
    return PreferredSize(
      preferredSize: Size(screenWidth, screenHeight * 0.07),
      child: AppBar(
        title: const Text('Attendance'),
        titleTextStyle: TextStyle(fontSize: (screenHeight * 0.07) * 0.4),
        titleSpacing: 0,
        foregroundColor: CustColors.white,
        backgroundColor: CustColors.dark_sky,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, size: (screenHeight * 0.07) * 0.5),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter Date', style: TextStyle(fontSize: screenWidth * 0.04)),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  contentPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                ),
                value: filterValue,
                items: ['All', 'Today', 'This Week', 'This Month', 'Custom']
                    .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: screenHeight * 0.02)),
                ))
                    .toList(),
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      filterValue = value;
                      _attendanceFuture = _getAttendance(value);
                    });
                  }
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  filterValue = 'Custom';
                  _attendanceFuture = _getAttendance(filterValue);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              child: Icon(Icons.calendar_month_outlined, color: Colors.white, size: screenHeight * 0.03),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceData(double screenWidth, double screenHeight) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _attendanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CustCircularProgress());
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString(), screenWidth);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Data', style: TextStyle(fontSize: screenWidth * 0.04)));
        } else {
          final data = snapshot.data!;
          return Column(
            children: [
              if (filterValue != 'All' && attendanceCount != null)
                AttendanceSummaryCard(
                  absent: attendanceCount!['absent'] ?? 0,
                  late: attendanceCount!['late'] ?? 0,
                  present: attendanceCount!['present'] ?? 0,
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => attendanceCard(data: data[index]),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildErrorWidget(String error, double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red, size: screenWidth * 0.1),
          SizedBox(height: 5),
          Text('Failed to load data\n$error', textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.04)),
          SizedBox(height: 5),
          SizedBox(
            height: screenWidth * 0.09,
            width: screenWidth * 0.35,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustColors.dark_sky,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              onPressed: () {
                setState(() {
                  _attendanceFuture = _getAttendance(filterValue);
                });
              },
              child: Text('Retry', style: TextStyle(fontSize: screenWidth * 0.035)),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> convertToIntMap(Map<String, dynamic> source) {
    return source.map((key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0));
  }

  Future<List<Map<String, dynamic>>> _getAttendance(String filterBy) async {
    final connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult == ConnectivityResult.none) {
      _showSnackBar('No internet connection');
      return Future.error('No connection');
    }

    try {
      final token = Pref.instance.getString(Consts.teacherToken);
      if (token == null) return _handleError('Token Missing', 'Please log in again');

      Uri listUri;
      Uri? countUri;

      if (filterBy == 'All') {
        listUri = Uri.https(Urls.baseUrls, Urls.staffAttendanceList);
      } else {
        final dateRange = await getDateRange(context, filterBy);
        if (dateRange == null) return [];

        listUri = Uri.https(Urls.baseUrls, Urls.getStaffAttendanceV1, dateRange);
        countUri = Uri.https(Urls.baseUrls, Urls.staffAttendanceCountV1, dateRange);
      }

      final responses = await Future.wait([
        get(listUri, headers: _buildHeaders(token)),
        if (countUri != null) get(countUri, headers: _buildHeaders(token))
      ]);

      if (responses.length > 1 && responses[1].statusCode == 200) {
        final body = jsonDecode(responses[1].body);
        if (body[Consts.status] == 'Success') {
          attendanceCount = convertToIntMap(body['attendanceCountV1'][0]);
        } else {
          return _handleError('Error', 'Something went wrong, try again.');
        }
      }

      if (responses[0].statusCode == 200) {
        final body = jsonDecode(responses[0].body);
        if (body[Consts.status] == 'Success') {
          final dataList = filterBy == 'All' ? body['attendance'] : body['attendanceListV1'];
          return List<Map<String, dynamic>>.from(dataList);
        }
      }
      return _handleError('Error', 'Something went wrong, try again.');
    } catch (e) {
      return _handleError('Exception', e.toString());
    }
  }

  Map<String, String> _buildHeaders(String token) => {
    Consts.authorization: 'Bearer $token',
    Consts.content_type: 'application/json',
  };

  Future<List<Map<String, dynamic>>> _handleError(String title, String desc) {
    _showSnackBar(desc);
    return Future.error('$title: $desc');
  }

  void _showSnackBar(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white)),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      ),
    );
  }

  Future<Map<String, String>?> getDateRange(BuildContext context, String selectedFilter) async {
    final DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (selectedFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case 'This Week':
        startDate = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        endDate = startDate.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;
      case 'Custom':
        final picked = await showDateRangePicker(
          context: context,
          confirmText: 'Done',
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 1),
          initialDateRange: DateTimeRange(start: now.subtract(Duration(days: 6)), end: now),
        );
        if (picked == null) return null;
        startDate = picked.start;
        endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999);
        break;
      default:
        startDate = now;
        endDate = now;
    }

    final formatter = DateFormat("yyyy-MM-dd");
    return {
      'startDate': formatter.format(startDate),
      'endDate': formatter.format(endDate),
    };
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


class AttendanceSummaryCard extends StatelessWidget {
  final int present;
  final int absent;
  final int late;

  const AttendanceSummaryCard({
    super.key,
    required this.present,
    required this.absent,
    required this.late,
  });

  @override
  Widget build(BuildContext context) {
    final cardData = [
      {
        'title': 'Present',
        'value': present,
        'icon': Icons.check_circle,
        'color': Colors.green.shade100,
        'iconColor': Colors.green.shade700,
      },
      {
        'title': 'Absent',
        'value': absent,
        'icon': Icons.cancel,
        'color': Colors.red.shade100,
        'iconColor': Colors.red.shade700,
      },
      {
        'title': 'Late',
        'value': late,
        'icon': Icons.access_time,
        'color': Colors.orange.shade100,
        'iconColor': Colors.orange.shade700,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: cardData.map((data) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: data['color'] as Color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(data['icon'] as IconData, color: data['iconColor'] as Color, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    data['value'].toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: data['iconColor'] as Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

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