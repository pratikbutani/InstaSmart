import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instasmart/models/frame.dart';
import 'package:instasmart/models/frames_firebase_functions.dart';
import 'package:instasmart/models/size_config.dart';
import 'package:instasmart/screens/liked_screen.dart';
import 'package:instasmart/widgets/frame_widget.dart';
import '../categories.dart';
import '../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instasmart/screens/create_grid_screen.dart';

//https://www.youtube.com/watch?v=BUmewWXGvCA  --> reference link

//TODO: add 'Explore' and 'Liked' to topbar
//filter list base on that
// https://github.com/Ephenodrom/Flutter-Advanced-Examples/tree/master/lib/examples/filterList
class FramesScreen extends StatefulWidget {
  static const routeName = '/frames';
  @override
  _FramesScreenState createState() => _FramesScreenState();
}

class _FramesScreenState extends State<FramesScreen> {

  bool imagePressed = false;
  int imageNoPressed;
  final collectionRef = Firestore.instance.collection('Resized_Frames');
  String selectedCat = Categories.all;
  FramesFirebaseFunctions firebaseFrames = FramesFirebaseFunctions();

  List <Frame>frameList = new List<Frame>(); //initial list, not to be changed
  List<Frame> filteredFrameList = new List<Frame>(); //filtered list

  Future<List<Frame>> futList;

  @override
  void initState() {
    super.initState();
    print('init');
    futList = firebaseFrames.GetUrlAndIdFromFirestore(Categories.all);
    futList.then((value) {
      setState(() {
        frameList = value;
        filteredFrameList = frameList;
      });
    });



    imagePressed = false;

  }

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    //SizeConfig.blockSizeHorizontal * 90,
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                    margin: EdgeInsets.fromLTRB(
                        0, SizeConfig.blockSizeVertical * 2, 0, 10),
                    //  SizeConfig.blockSizeHorizontal * 2, 0, 0, 0),
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.blockSizeVertical * 5.5,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: Categories.catNamesList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          new CategoryButton(
                        catName: Categories.catNamesList[index],
                        selectedCat: selectedCat,
                        ontap: () => setState(() {
                          selectedCat = Categories.catNamesList[index];
                          filteredFrameList = FramesFirebaseFunctions()
                              .filterFrames(selectedCat, frameList);

                        }),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: futList,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Frame>> snapshot) {

                      if (!snapshot.hasData) {
                        return Container();
                      }
                      else {
                        print('build future');
                        return Expanded(
                          child: GridView.builder(
                              itemCount: filteredFrameList.length,
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                              itemBuilder: (BuildContext context, int index) =>
                                  Container(
                                      child: Hero(
                                        tag: index,
                                        child: buildFrameToDisplay(index),
                                      ))),
                        );
                      }
                      //TODO: I need to do this

                    }),
                ]),
            imagePressed ? buildPopUpImage(imageNoPressed) : Container(), //
          ],
        ),
      ),
    );
  }

  Widget buildFrameToDisplay(int index) {
    try {
      Frame_Widget frameWidget =
          new Frame_Widget(frame: filteredFrameList[index], isLiked: false);
      //isLiked should be true if image exists in user's likedframes collection.
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateScreen(filteredFrameList[index].imgurl, index),
              ));
        },
        onLongPress: () {
          print("longpress");
          //show pop up image
          setState(() {
            imagePressed = true;
            imageNoPressed = index;
          });
          print(index);
        },
        onLongPressUp: () {
          //set state of longPressed to false
          setState(() {
            imagePressed = false;
          });
        },
        child: frameWidget,
      );
    } catch (e) {
      print('error in building screen is');
      //  tryFrame();
      print(e);
    }
  }

  Widget buildPopUpImage(int index) {
    return Container(
      alignment: Alignment.center,
      color: Color(0x88000000),
      child: Container(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
                color: Colors.white,
                child: CachedNetworkImage(
                    imageUrl: filteredFrameList[index].imgurl))),
      ),
    );
  }
}

class CategoryButton extends StatefulWidget {
  final String catName;
  final Function ontap;
  final String selectedCat;

  const CategoryButton(
      {Key key,
      @required this.catName,
      @required this.ontap,
      @required this.selectedCat})
      : super(key: key);

  @override
  _CategoryButtonState createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool isPressed = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
      child: RaisedButton(
        elevation: 0,
        //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Text("#" + widget.catName,
            style: widget.selectedCat == widget.catName
                ? TextStyle(
                    color: Constants.paleBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)
                : TextStyle(
                    color: Constants.lightPurple,
                    fontSize: 17,
                  )),
        color: widget.selectedCat == widget.catName
            ? Colors.transparent
            : Colors.transparent,
        shape: Constants.buttonShape,
        onPressed: widget.ontap,
        focusColor: Constants.brightPurple,
        hoverColor: Colors.white,
        splashColor: Constants.lightPurple,

        //function to change selectedVar goes here
      ),
    );
  }
}

class PageTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppBar appBar;
  final List<Widget> widgets;

  /// you can add more fields that meet your needs
  const PageTopBar({Key key, this.title, this.appBar, this.widgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
      actions: widgets,
      iconTheme:
          IconThemeData(color: Constants.paleBlue //change your color here
              ),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
