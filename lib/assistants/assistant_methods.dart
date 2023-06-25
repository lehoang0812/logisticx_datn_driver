import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logisticx_datn_driver/assistants/request_assistant.dart';
import 'package:logisticx_datn_driver/global/global.dart';
import 'package:logisticx_datn_driver/global/map_key.dart';
import 'package:logisticx_datn_driver/models/direction_details_info.dart';
import 'package:logisticx_datn_driver/models/trips_history_model.dart';
import 'package:logisticx_datn_driver/models/user_model.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';
import '../models/directions.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://nominatim.openstreetmap.org/ui/reverse.html?lat=${position.latitude}&${position.longitude}";
    // "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occured. Failed. No Response.") {
      humanReadableAddress = requestResponse["display_name"][0];
      // humanReadableAddress = requestResponse["results"][0][
      // "formatted_address"]; //"CWH7+5P Mountain View, California, Hoa K\u1ef3";

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongtitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;
    double totalFareAmount = distanceTraveledFareAmountPerKilometer * 22000;
    double localCurrencyTotalFare = totalFareAmount * 10;

    if (driverVehicleType == "Bike") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
      print("Giá xe máy: ${resultFareAmount}");
      return resultFareAmount;
    } else if (driverVehicleType == "Car") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 1.5);
      print("Giá ô tô: ${resultFareAmount}");
      return resultFareAmount;
    } else if (driverVehicleType == "Truck") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 3);
      print("Giá xe tải: ${resultFareAmount}");
      return resultFareAmount;
    } else {
      print("Giá trung bình: ${localCurrencyTotalFare.truncate().toDouble()}");
      return localCurrencyTotalFare.truncate().toDouble();
    }
    // return localCurrencyTotalFare.truncate().toDouble();
  }

  //retrieve the trips keys for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineDriver(context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(firebaseAuth.currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //dem tong so don hang va` share it with Provider
        int overallTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false)
            .updateOverallTripsCounter(overallTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false)
            .updateOverallTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete info
        readTripsHistoryInfo(context);
      }
    });
  }

  static void readTripsHistoryInfo(context) {
    var tripsAllKeys =
        Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;
    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if ((snap.snapshot.value as Map)["status"] == "ended") {
          Provider.of<AppInfo>(context, listen: false)
              .updateOverallTripsHistoryInfo(eachTripHistory);
        }
      });
    }
  }

  //readDriverEarnings
  static void readDriverEarnings(context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false)
            .updateDriverTotalEarnings(driverEarnings);
      }
    });
    readTripsKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("ratings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false)
            .updateDriverAverageRatings(driverRatings);
      }
    });
  }
}
