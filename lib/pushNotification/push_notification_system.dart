import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logisticx_datn_driver/global/global.dart';
import 'package:logisticx_datn_driver/models/user_ride_request_info.dart';

import 'notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //1. terminated
    //khi app đang đóng và đc mở trực tiếp từ thanh thông báo
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInfo(remoteMessage.data["rideRequestId"], context);
      }
    });

    //2. foreground
    //Khi ứng dụng đang mở và nhận đc thông báo đẩy
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInfo(remoteMessage!.data["rideRequestId"], context);
    });

    //3. background
    //Khi ứng dụng chạy nền và đc mở từ thanh thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInfo(remoteMessage!.data["rideRequestId"], context);
    });
  }

  readUserRideRequestInfo(String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .child("driverId")
        .onValue
        .listen((event) {
      if (event.snapshot.value == "waiting" ||
          event.snapshot.value == firebaseAuth.currentUser!.uid) {
        FirebaseDatabase.instance
            .ref()
            .child("All Ride Requests")
            .child(userRideRequestId)
            .once()
            .then((snapData) {
          if (snapData.snapshot.value != null) {
            double originLat = double.parse(
                (snapData.snapshot.value! as Map)["origin"]["latitude"]);
            double originLng = double.parse(
                (snapData.snapshot.value! as Map)["origin"]["longitude"]);
            String originAddress =
                (snapData.snapshot.value! as Map)["originAddress"];

            double destinationLat = double.parse(
                (snapData.snapshot.value! as Map)["destination"]["latitude"]);
            double destinationLng = double.parse(
                (snapData.snapshot.value! as Map)["destination"]["longitude"]);
            String destinationAddress =
                (snapData.snapshot.value! as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInfo userRideRequestDetails = UserRideRequestInfo();
            userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
            userRideRequestDetails.originAddress = originAddress;
            userRideRequestDetails.destinationLatLng =
                LatLng(destinationLat, destinationLng);
            userRideRequestDetails.destinationAddress = destinationAddress;
            userRideRequestDetails.userName = userName;
            userRideRequestDetails.userPhone = userPhone;

            userRideRequestDetails.rideRequestId = rideRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox(
                      userRideRequestDetails: userRideRequestDetails,
                    ));
          } else {
            Fluttertoast.showToast(msg: "Không tìm thấy ID chuyến hàng.");
          }
        });
      } else {
        Fluttertoast.showToast(msg: "Chuyến hàng này đã bị hủy.");
        Navigator.pop(context);
      }
    });
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("Mã đăng ký: $registrationToken");

    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
