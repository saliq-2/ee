
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AboutUs.dart';
import 'Directory/search.dart';
import 'calendar/homepage.dart';

class BNavBar extends StatefulWidget {
  const BNavBar({super.key});

  @override
  State<BNavBar> createState() => _BNavBar();
}

class _BNavBar extends State<BNavBar> {
  int index = 0;
  final screens = [
    const MyHomePage(),
    const DirectoryInSearch(),
    const AboutUs()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[index],
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
              elevation: 50,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13.0), // Customize the border radius
              ),
              indicatorColor: Colors.pinkAccent,
              labelTextStyle: MaterialStateProperty.all( TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.height*0.014,
                  color: Colors.black))),
          child: NavigationBar(
            height: MediaQuery.of(context).size.height*0.09,
            elevation: 90,
            shadowColor: CupertinoColors.white,
            backgroundColor: CupertinoColors.lightBackgroundGray,
            selectedIndex: index,
            // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            animationDuration: const Duration(seconds: 2),

            onDestinationSelected: (index) => setState(() {
              this.index = index;
            }),
            destinations:  [
              NavigationDestination(
                  icon:  Icon(Icons.calendar_month,size:MediaQuery.of(context).size.height*0.03,),
                  selectedIcon: Icon(Icons.calendar_month,size: MediaQuery.of(context).size.height*0.03,color: Colors.white,),
                  label: 'Calendar',),
              NavigationDestination(
                  icon: Icon(Icons.search,size: MediaQuery.of(context).size.height*0.03,),
                selectedIcon:Icon(Icons.search,size: MediaQuery.of(context).size.height*0.03,color: Colors.white,),
                label: 'Directory',),
              NavigationDestination(
                  icon: Icon(Icons.info,size: MediaQuery.of(context).size.height*0.03,),
                  selectedIcon:Icon(Icons.info,size: MediaQuery.of(context).size.height*0.03,color: Colors.white,),

                  label: 'About Us'),

            ],
          ),
        ));
  }
}
