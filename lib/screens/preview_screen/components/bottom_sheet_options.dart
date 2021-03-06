// Dart imports:
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instasmart/components/custom_dialog_widget.dart';
import 'package:instasmart/constants.dart';
import 'package:instasmart/screens/HomeScreen.dart';
import 'package:instasmart/screens/reminder_screen/reminder_create_form.dart';
import 'package:instasmart/services/firebase_image_storage.dart';
import 'package:instasmart/utils/helper.dart';
import 'package:instasmart/utils/save_images.dart';
import 'package:instasmart/utils/size_config.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';

class BottomSheetOptions extends StatelessWidget {
  const BottomSheetOptions({
    Key key,
    this.screen,
    this.firebaseStorage,
    @required this.imageUrl,
  }) : super(key: key);

  final FirebaseImageStorage firebaseStorage;
  final String imageUrl;
  final String screen;
  final String CalenderScreen = 'Calender';
  final String PreviewScreen = 'Preview';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.safeBlockVertical * 75,
      decoration: new BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(25.0),
          topRight: const Radius.circular(25.0),
        ),
      ),
      child: Material(
        child: Column(
          children: <Widget>[
            Container(
              width: SizeConfig.screenWidth / 2,
              height: SizeConfig.screenWidth / 2,
              child: Hero(
                  tag: imageUrl, child: CachedNetworkImage(imageUrl: imageUrl)),
            ),
            screen == PreviewScreen
                ? ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                    ),
                    title: Text('Schedule Post'),
                    onTap: () async {
                      var navigationResult = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReminderForm(imageUrl),
                        ),
                      );
                      if (navigationResult == 'reminder_created') {
                        Flushbar(
                          message: "Post reminder has been set",
                          backgroundColor: Constants.lightPurple,
                          duration: Duration(seconds: 3),
                          mainButton: FlatButton(
                              onPressed: () {
                                push(
                                    context,
                                    HomeScreen(
                                      index: 3,
                                    ));
                              },
                              child: Text('View')),
                        )..show(context);
                      }
                    })
                : Container(),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Share to Instagram'),
              onTap: () async {
                Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imageUrl))
                        .load(imageUrl))
                    .buffer
                    .asUint8List();
                await Share.file(
                  'instasmart image',
                  'instasmart-image.png',
                  bytes,
                  'image/png',
                );
//              File file = await urlToFile(imageUrl);
//              await SocialSharePlugin.shareToFeedInstagram(path: file.path);
              },
            ),
            ListTile(
              leading: Icon(Icons.save_alt),
              title: Text('Save to Phone'),
              onTap: () async {
                var imgBytes = await networkImageToByte(imageUrl);
                saveImages([imgBytes]);
                showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialogWidget(
                          title: 'Saved!',
                          body: 'Images have been saved to gallery',
                        ));
              },
            ),
            screen == PreviewScreen
                ? ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () async {
                      await firebaseStorage.deleteImages([imageUrl]);
                      Navigator.pop(context);
                      await Flushbar(
                          message: "Post has been deleted",
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3))
                        ..show(context);
                    },
                  )
                : Container(),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Close'),
              onTap: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }
}
