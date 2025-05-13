import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_teacher/initities/colors.dart';
import 'package:school_teacher/initities/consts.dart';
import 'package:school_teacher/initities/permission_handler.dart';
import 'package:school_teacher/screens/navigation/attendance_screen.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';
import '../model/teacher.dart';
import 'authentication/login_screen.dart';
import 'navigation/home_screen.dart';


class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Widget> _screens = [];
  int _currentIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  // static final List<String> titles = ['Home','Profile','Payslip','Attendance'];
  static final List<String> titles = ['Home','Attendance'];

  @override
  void initState() {
    super.initState();
    // _screens = [HomeScreen(),ProfileScreen(),PayslipScreen(),AttendanceScreen()];
    _screens = [HomeScreen(),AttendanceScreen()];
    getLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustColors.dark_sky,
        // centerTitle: true,
        title: Text(titles[_currentIndex], style:Theme.of(context).textTheme.bodyMedium!.copyWith(color: CustColors.white)),
        leading: Builder(builder:(context)=> IconButton(onPressed:(){Scaffold.of(context).openDrawer();},icon: Icon(Icons.menu, color: CustColors.white))),
      ),
      body: IndexedStack(
        index: _currentIndex,
          children: _screens
      ),

      drawer: _drawerUI(),
      // Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        key: _bottomNavigationKey,
        color: CustColors.dark_sky,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        iconPadding: 16,
        letIndexChange: (index){

          return true;
        },
        animationDuration: Duration(milliseconds: 600),
        items: [
          CurvedNavigationBarItem(
            child: Icon(FontAwesomeIcons.house,size: 20,color: CustColors.white,),
           // Image.asset('assets/icons/home.webp',width: 27,height: 27,color: CustColors.white,),
            label: 'Home',
            labelStyle: TextStyle(color: CustColors.white,fontSize: 12)
          ),
          // CurvedNavigationBarItem(
          //   child: Icon(FontAwesomeIcons.userLarge,size: 20,color: CustColors.white,),
          //   // Image.asset('assets/icons/profile.webp',width: 27,height: 27,color: CustColors.white,),
          //   label: 'Profile',
          //     labelStyle: TextStyle(color: CustColors.white,fontSize: 12)
          // ),
          // CurvedNavigationBarItem(
          //   child: Icon(FontAwesomeIcons.wallet,size: 20,color: CustColors.white,),
          //   // Image.asset('assets/icons/payslip.webp',width: 27,height: 27,color: CustColors.white,),
          //   label: 'Payslip',
          //     labelStyle: TextStyle(color: CustColors.white,fontSize: 12)
          // ),
          CurvedNavigationBarItem(
            child: Icon(FontAwesomeIcons.userCheck,size: 20,color: CustColors.white,),
            // Image.asset('assets/icons/attendance.webp',width: 27,height: 27,color: CustColors.white,),
            label: 'Attendance',
              labelStyle: TextStyle(color: CustColors.white,fontSize: 12)
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      // CurvedNavigationBar(
      //   buttonBackgroundColor: Colors.transparent,
      //     backgroundColor: Colors.transparent,
      //     color: CustColors.dark_sky,
      //     animationDuration: Duration(milliseconds: 300),
      //     animationCurve: Curves.bounceInOut,
      //     height: 60.0,
      //
      //     items: <Widget>[
      //       Icon(FontAwesomeIcons.home,size: 30,),
      //       Icon(FontAwesomeIcons.person,size: 30,),
      //       Icon(FontAwesomeIcons.wallet,size: 30,),
      //       Icon(FontAwesomeIcons.markdown,size: 30,),
      //     ],
      // ),
      // BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white,
      //   backgroundColor:  Color(0xFF1A2A4F),
      //   currentIndex: _currentIndex,
      //   onTap: (index){
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: BottomNavigationIcon(icon: Icons.home,iconColor: Colors.white, opacity: 0,),
      //       activeIcon: BottomNavigationIcon(icon: Icons.home,iconColor: Colors.black87, opacity: 1,),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: BottomNavigationIcon(icon: Icons.person,iconColor: Colors.white,opacity: 0,),
      //       activeIcon: BottomNavigationIcon(icon: Icons.person,iconColor: Colors.black87, opacity: 1,),
      //       label: 'Profile',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: BottomNavigationIcon(icon: Icons.account_balance_wallet_rounded,iconColor: Colors.white,opacity: 0,),
      //       activeIcon: BottomNavigationIcon(icon: Icons.account_balance_wallet_rounded,iconColor: Colors.black87, opacity: 1,),
      //       label: 'Payslip',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: BottomNavigationIcon(icon: Icons.co_present_rounded,iconColor: Colors.white,opacity: 0,),
      //       activeIcon: BottomNavigationIcon(icon: Icons.co_present_rounded,iconColor: Colors.black87, opacity: 1,),
      //       label: 'Attendance',
      //     ),
      //   ],
      // ),
    );
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

}
