import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logisticx_datn_driver/global/global.dart';
import 'package:logisticx_datn_driver/splashScreen/splash_screen.dart';

class ProfileTabPage extends StatefulWidget {
  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

  Future<void> showDriverNameDialogAlert(BuildContext context, String name) {
    nameTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameTextEditingController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Hủy bỏ",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "name": nameTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Cập nhật thành công, vui lòng load lại để xem thay đổi");
                }).catchError((e) {
                  Fluttertoast.showToast(msg: "Lỗi xảy ra: " + e);
                });
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDriverPhoneDialogAlert(BuildContext context, String phone) {
    phoneTextEditingController.text = phone;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: phoneTextEditingController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Hủy bỏ",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "phone": phoneTextEditingController.text.trim(),
                }).then((value) {
                  phoneTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Cập nhật thành công, vui lòng load lại để xem thay đổi");
                }).catchError((e) {
                  Fluttertoast.showToast(msg: "Lỗi xảy ra: " + e);
                });
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDriverAddressDialogAlert(
      BuildContext context, String address) {
    addressTextEditingController.text = address;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: addressTextEditingController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Hủy bỏ",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "address": addressTextEditingController.text.trim(),
                }).then((value) {
                  addressTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Cập nhật thành công, vui lòng load lại để xem thay đổi");
                }).catchError((e) {
                  Fluttertoast.showToast(msg: "Lỗi xảy ra: " + e);
                });
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Text(
            "Thông tin cá nhân",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "${onlineDriverData.email!}",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${onlineDriverData.name!}",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDriverNameDialogAlert(
                                context, onlineDriverData.name!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${onlineDriverData.phone!}",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDriverNameDialogAlert(
                                context, onlineDriverData.phone!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${onlineDriverData.address!}",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDriverNameDialogAlert(
                                context, onlineDriverData.address!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${onlineDriverData.car_model!} \n${onlineDriverData.car_color!} (${onlineDriverData.car_number!})",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Image.asset(
                          onlineDriverData.car_type == "Car"
                              ? "./assets/car.png"
                              : onlineDriverData.car_type == "Truck"
                                  ? "./assets/truck.png"
                                  : "./assets/bike.png",
                          scale: 2,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        firebaseAuth.signOut();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (c) => SplashScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text(
                        "Đăng xuất",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
