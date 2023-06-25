import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logisticx_datn_driver/assistants/assistant_methods.dart';
import 'package:logisticx_datn_driver/models/user_ride_request_info.dart';
import 'package:logisticx_datn_driver/splashScreen/splash_screen.dart';
import 'package:logisticx_datn_driver/widgets/fare_amount_collection_dialog.dart';
import 'package:logisticx_datn_driver/widgets/progress_dialog.dart';

import '../global/global.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInfo? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGGMapController;
  final Completer<GoogleMapController> _controllerGGMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Đã đến nơi nhận";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarker = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geolocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

//buoc 1: khi tai xe chap nhan yeu cau chuyen hang cua user
//originLatLng = driverCurrent location
//destinationLatLng = user pickup location

//buoc 2: khi tai xe nhan hang len xe
//originLatLng = user current location = driver current location at that time
//destinationLatLng = user's drop-off location
  Future<void> drawPolylineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Vui lòng chờ...",
      ),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints polyPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        polyPoints.decodePolyline(directionDetailsInfo.e_points!);

    polylinePositionCoordinates.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        polylinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      latLngBounds =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGGMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.blueAccent,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.redAccent,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfMarker.add(originMarker);
      setOfMarker.add(destinationMarker);
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

  getDriverLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "Vị trí của bạn"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 18);
        newTripGGMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarker.removeWhere((p) => p.markerId.value == "AnimatedMarker");
        setOfMarker.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //cap nhat vi tri driver at real time in database
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("driverLocation")
          .set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if (rideRequestStatus == "accepted") {
        destinationLatLng =
            widget.userRideRequestDetails!.originLatLng; //user pickup location
      } else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }

      var directionInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);

      if (directionInfo != null) {
        setState(() {
          durationFromOriginToDestination = directionInfo.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  // createDriverIconMarker() {
  //   if (iconAnimatedMarker == null) {
  //     ImageConfiguration imageConfiguration =
  //         createLocalImageConfiguration(context, size: Size(2, 2));
  //     BitmapDescriptor.fromAssetImage(imageConfiguration, "./assets/car.png")
  //         .then((value) {
  //       iconAnimatedMarker = value;
  //     });
  //   }
  // }

  Future<void> createDriverIconMarker() async {
    if (iconAnimatedMarker == null) {
      ByteData byteData = await rootBundle.load('./assets/car.png');
      Uint8List imageData = byteData.buffer.asUint8List();

      // Thay đổi kích thước hình ảnh và nén
      Uint8List compressedImageData =
          await FlutterImageCompress.compressWithList(
        imageData,
        minHeight: 2, // Chiều cao tối thiểu sau khi thu nhỏ
        minWidth: 2, // Chiều rộng tối thiểu sau khi thu nhỏ
        quality: 80, // Chất lượng hình ảnh sau khi nén (từ 0-100)
      );

      iconAnimatedMarker = BitmapDescriptor.fromBytes(compressedImageData);
    }
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };

    if (databaseReference.child("driverId") != "waiting") {
      databaseReference.child("driverLocation").set(driverLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("ratings").set(onlineDriverData.ratings);
      databaseReference.child("car_details").set(
          onlineDriverData.car_model.toString() +
              " " +
              onlineDriverData.car_number.toString() +
              " (" +
              onlineDriverData.car_color.toString() +
              ")");

      saveRideRequestIdToDriverHistory();
    } else {
      Fluttertoast.showToast(
          msg:
              "Đơn này đã được nhận bởi một tài xế khác. \n Vui lòng tải lại ứng dụng");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => SplashScreen()));
    }
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripsHistory");

    tripsHistoryRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }

  endTripNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Vui lòng đợi...",
      ),
    );

    //get the tripDirectionDetails = distance travelled
    var currentDriverPositionLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude);

    var tripDirectionDetails =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            currentDriverPositionLatLng,
            widget.userRideRequestDetails!.originLatLng!);

    //gia tien`
    double totalFareAmount =
        AssistantMethods.calculateFareAmountFromOriginToDestination(
            tripDirectionDetails);

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status")
        .set("ended");

    Navigator.pop(context);

    //display fare amount in dialog box
    showDialog(
        context: context,
        builder: (BuildContext context) => FareAmountCollectionDialog(
              totalFareAmount: totalFareAmount,
            ));

    //save fare amount to driver total earnings
    saveFareAmountToDriverEarnings(totalFareAmount);
  }

  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseAuth.currentUser!.uid)
            .child("earnings")
            .set(driverTotalEarnings.toString());
      } else {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseAuth.currentUser!.uid)
            .child("earnings")
            .set(totalFareAmount.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarker,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGGMap.complete(controller);
              newTripGGMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var userPickupLatLng =
                  widget.userRideRequestDetails!.originLatLng;

              drawPolylineFromOriginToDestination(
                  driverCurrentLatLng, userPickupLatLng!);

              getDriverLocationUpdatesAtRealTime();
            },
          ),

          //ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                      spreadRadius: 0.5,
                      offset: Offset(0.6, 0.6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      //duration
                      Text(
                        durationFromOriginToDestination,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.userRideRequestDetails!.userName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.phone,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          Image.asset(
                            "./assets/origin.png",
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.userRideRequestDetails!.originAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          Image.asset(
                            "./assets/destination.png",
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.userRideRequestDetails!
                                    .destinationAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      ElevatedButton.icon(
                        onPressed: () async {
                          //tai xe da den noi nhan hang - button "Đã đến nơi"
                          if (rideRequestStatus == "accepted") {
                            rideRequestStatus = "arrived";

                            FirebaseDatabase.instance
                                .ref()
                                .child("All Ride Requests")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("status")
                                .set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "Đi thôi";
                              buttonColor = Colors.lightGreen;
                            });

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => ProgressDialog(
                                message: "Đang load...",
                              ),
                            );

                            await drawPolylineFromOriginToDestination(
                              widget.userRideRequestDetails!.originLatLng!,
                              widget.userRideRequestDetails!.destinationLatLng!,
                            );
                            Navigator.pop(context);
                          }
                          //user da giao hang cho tai xe - dc rui di thuii
                          else if (rideRequestStatus == "arrived") {
                            rideRequestStatus = "ontrip";

                            FirebaseDatabase.instance
                                .ref()
                                .child("All Ride Requests")
                                .child(widget
                                    .userRideRequestDetails!.rideRequestId!)
                                .child("status")
                                .set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "Giao hàng thành công";
                              buttonColor = Colors.red;
                            });
                          }
                          //tai xe da den diem giao hang - end trip button
                          else if (rideRequestStatus == "ontrip") {
                            endTripNow();
                          }
                        },
                        icon: Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: Text(
                          buttonTitle!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
