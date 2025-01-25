import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_teacher/initities/colors.dart';
import 'package:school_teacher/initities/permission_handler.dart';
import 'package:school_teacher/screens/navigation/attendance_screen.dart';
import 'package:school_teacher/screens/navigation/payslip_screen.dart';
import 'package:school_teacher/screens/navigation/profile_screen.dart';
import '../widgets/bottom_navigation_icon.dart';
import 'navigation/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Widget> _screens = [];
  int _currentIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  static final List<String> titles = ['Home','Profile','Payslip','Attendance'];

  @override
  void initState() {
    super.initState();
    _screens = [HomeScreen(),ProfileScreen(),PayslipScreen(),AttendanceScreen()];
    getLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustColors.dark_sky,
        centerTitle: true,
        title: Text(titles[_currentIndex], style:Theme.of(context).textTheme.bodyMedium!.copyWith(color: CustColors.white)),
        leading: Builder(builder:(context)=> IconButton(onPressed:(){Scaffold.of(context).openDrawer();},icon: Icon(Icons.menu, color: CustColors.white))),
      ),
      body: _screens[_currentIndex],

      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: CustColors.dark_sky,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(20.0),bottomLeft: Radius.circular(20.0))
                ),
              ),
            ),
            Expanded(
              flex: 4,
                child: Container(
              decoration: BoxDecoration(
                color: CustColors.background
              ),
            ))
          ],
        ),
      ),
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
          CurvedNavigationBarItem(
            child: Icon(FontAwesomeIcons.userLarge,size: 20,color: CustColors.white,),
            // Image.asset('assets/icons/profile.webp',width: 27,height: 27,color: CustColors.white,),
            label: 'Profile',
              labelStyle: TextStyle(color: CustColors.white,fontSize: 12)
          ),
          CurvedNavigationBarItem(
            child: Icon(FontAwesomeIcons.wallet,size: 20,color: CustColors.white,),
            // Image.asset('assets/icons/payslip.webp',width: 27,height: 27,color: CustColors.white,),
            label: 'Payslip',
              labelStyle: TextStyle(color: CustColors.white,fontSize: 12)
          ),
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
}
