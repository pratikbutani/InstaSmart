// Flutter imports:
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instasmart/components/template_button.dart';
import 'package:instasmart/components/tip_widgets.dart';
import 'package:instasmart/constants.dart';
import 'package:instasmart/models/user.dart';
import 'package:instasmart/screens/preview_screen/components/bottom_sheet_options.dart';
import 'package:instasmart/screens/preview_screen/components/preview_photo.dart';
import 'package:instasmart/services/firebase_image_storage.dart';
import 'package:instasmart/services/login_functions.dart';
import 'package:instasmart/utils/helper.dart';
import 'package:instasmart/utils/size_config.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shimmer/shimmer.dart';

import '../../HomeScreen.dart';

class ReorderableGrid extends StatelessWidget {
  const ReorderableGrid(
      {Key key,
      @required this.firebase,
      @required this.firebaseStorage,
      @required this.user})
      : super(key: key);

  final FirebaseLoginFunctions firebase;
  final FirebaseImageStorage firebaseStorage;
  final User user;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection(Constants.USERS)
            .document(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return FutureBuilder<List>(
                future: firebaseStorage.getImageUrls(),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      child: GridView.builder(
                        itemCount: 15,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                        itemBuilder: (BuildContext context, int index) =>
                            Container(
                          child: Hero(
                            tag: index,
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                height: SizeConfig.screenWidth / 3,
                                width: SizeConfig.screenWidth / 3,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    bool hasFrames;
                    hasFrames = snapshot.data.length == 0;
                    if (hasFrames) {
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TipTextWidget(
                              tipBody:
                                  "You haven't created any grids yet.\nCreate & view them here!",
                            ),
                            Container(
                              width: SizeConfig.blockSizeHorizontal * 40,
                              padding: EdgeInsets.only(
                                  top: SizeConfig.blockSizeVertical * 5),
                              child: TemplateButton(
                                title: 'Get Started!',
                                iconType: Icons.navigate_next,
                                color: Constants.palePink,
                                ontap: () {
                                  pushAndRemoveUntil(
                                      context, HomeScreen(user: user), false);
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        child: ReorderableWrap(
                            minMainAxisCount: 3,
                            spacing: 1.0,
                            runSpacing: 1.0,
                            padding: const EdgeInsets.all(0),
                            children:
                                List.generate(snapshot.data.length, (index) {
                              return Container(
                                height: SizeConfig.screenWidth / 3,
                                width: SizeConfig.screenWidth / 3,
                                child: FittedBox(
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              BottomSheetOptions(
                                                firebaseStorage:
                                                    firebaseStorage,
                                                imageUrl: snapshot.data[index],
                                                screen: 'Preview',
                                              ));
                                    },
                                    onDoubleTap: () {
                                      showGeneralDialog(
                                        barrierDismissible: true,
                                        barrierLabel: '',
                                        barrierColor:
                                            Colors.black.withOpacity(0.1),
                                        transitionDuration:
                                            Duration(milliseconds: 100),
                                        pageBuilder: (ctx, anim1, anim2) => //
                                            Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.all(5),
                                          child: Container(
                                              width: double.infinity,
                                              height: 300,
                                              child: PhotoView.customChild(
                                                minScale: 1.0,
                                                backgroundDecoration:
                                                    BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0)),
                                                child: PreviewPhoto(
                                                    snapshot.data[index]),
                                              )),
                                        ),
                                        transitionBuilder:
                                            (ctx, anim1, anim2, child) =>
                                                BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 8 * anim1.value,
                                              sigmaY: 8 * anim1.value),
                                          child: FadeTransition(
                                            child: child,
                                            opacity: anim1,
                                          ),
                                        ),
                                        context: context,
                                      );
                                    },
                                    child: Hero(
                                      tag: snapshot.data[index],
                                      child: PreviewPhoto(snapshot.data[index]),
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              );
                            }),
                            onReorder: (int oldIndex, int newIndex) {
                              firebaseStorage.reorderImageArray(
                                  oldIndex, newIndex);
                            },
                            onNoReorder: (int index) {
                              //this callback is optional
                              debugPrint(
                                  '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                            },
                            onReorderStarted: (int index) {
                              //this callback is optional
                              debugPrint(
                                  '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
                            }),
                      );
                    }
                  }
                });
          }
        });
  }
}
