import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_teacher/initities/consts.dart';
import 'package:school_teacher/screens/authentication/login_screen.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';

import '../../initities/colors.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 70.0,
                      backgroundImage: NetworkImage(
                        'https://storage.googleapis.com/a1aa/image/lbnwHobqtCaxONelBvZmW9NlAveeDeb5fMlWmeA4O8N0tdDCF.jpg',
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'PRABHAT RAJ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'DPINT10030',
                      style: TextStyle(color: CustColors.grey,fontSize: 14),
                    ),
                    SizedBox(height: 15.0,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustColors.dark_sky,
                          foregroundColor: CustColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                        ),
                        child: Text('Change Password'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Employee ID', 'DPINT10030'),
                    _buildInfoRow('Designation', 'Web Developer'),
                    _buildInfoRow('Employee Type', 'Intern'),
                    _buildInfoRow('Department', 'MANAGEMENT'),
                    _buildInfoRow('Gender', 'Male'),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.5,
                child: ElevatedButton(
                  onPressed: () {
                    // Pref.instance.clear();
                    Pref.instance.remove(Consts.isLogin);
                    Pref.instance.remove(Consts.teacherToken);
                    Pref.instance.remove(Consts.organisationId);
                    Pref.instance.remove(Consts.organisationCode);
                    Pref.instance.remove(Consts.teacherCode);
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LoginScreen()), (route) => false,);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                  ),
                  child: Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: CustColors.grey,
              fontSize: 16.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.0,
              color: CustColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          Divider(color: CustColors.grey.withOpacity(0.3),)
        ],
      ),
    );
  }
}