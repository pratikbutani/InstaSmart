// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:instasmart/constants.dart';
import 'package:instasmart/custom_packages/bottom_navy_bar_custom/bottom_navy_bar_custom.dart';
import 'package:instasmart/main.dart';
import 'package:instasmart/models/user.dart';
import 'package:instasmart/screens/calendar_screen/calendar_screen.dart';
import 'package:instasmart/screens/frames_screen/frames_screen.dart';
import 'package:instasmart/screens/liked_screen/liked_screen.dart';
import 'package:instasmart/screens/preview_screen/preview_screen.dart';
import 'package:instasmart/screens/profile_screen/profile_screen.dart';
import 'profile_screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  static const routeName = '/home';
  final int index;

  HomeScreen({Key key, this.user, this.index}) : super(key: key);

  @override
  State createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  _HomeState();
  int _currentIndex;
  PageController _pageController;
  User user = MyAppState.currentUser;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index == null ? 0 : widget.index;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: <Widget>[
              Container(
                child: FramesScreen(),
              ),
              Container(
                child: LikedScreen(),
              ),
              Container(
                child: PreviewScreen(),
              ),
              Container(
                child: CalendarScreen(),
              ),
              Container(
                child: SettingsPage(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavyBarCustom(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(index);
          },
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: <BottomNavyBarCustomItem>[
            BottomNavyBarCustomItem(
              title: Text('Explore'),
              icon: Icon(Icons.search),
              activeColor: Theme.of(context).primaryColor,
            ),
            BottomNavyBarCustomItem(
              title: Text('Liked'),
              icon: Icon(
                Icons.favorite_border,
              ),
              activeColor: Theme.of(context).primaryColor,
            ),
            BottomNavyBarCustomItem(
              title: Text('My Feed'),
              icon: Icon(Icons.apps),
              activeColor: Theme.of(context).primaryColor,
            ),
            BottomNavyBarCustomItem(
              title: Text(
                'Calender',
                style: TextStyle(fontSize: 14, letterSpacing: 0.5),
              ),
              icon: Icon(Icons.access_time),
              activeColor: Theme.of(context).primaryColor,
            ),
            BottomNavyBarCustomItem(
              title: Text('Profile'),
              icon: Icon(
                Icons.account_circle,
              ),
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
