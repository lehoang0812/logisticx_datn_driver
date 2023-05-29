import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logisticx_datn_driver/global/global.dart';
import 'package:logisticx_datn_driver/splashScreen/splash_screen.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController carModelController = TextEditingController();
  TextEditingController carNumberController = TextEditingController();
  TextEditingController carColorController = TextEditingController();

  List<String> carTypes = ["Car", "CNG", "Bike"];
  String? selectedCarType;

  final _formKey = GlobalKey<FormState>();

  _register() {
    if (_formKey.currentState!.validate()) {
      Map driverCarInfoMap = {
        "car_model": carModelController.text.trim(),
        "car_number": carNumberController.text.trim(),
        "car_color": carColorController.text.trim(),
      };

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("drivers");
      userRef
          .child(currentUser!.uid)
          .child("car_details")
          .set(driverCarInfoMap);

      Fluttertoast.showToast(msg: "Thêm phương tiện thành công");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => SplashScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image(
                    image: AssetImage('./assets/ic_car_green.png'),
                    fit: BoxFit.cover),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Thêm phương tiện",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    controller: carModelController,
                    decoration: InputDecoration(
                        labelText: 'Hãng xe',
                        prefixIcon: Container(
                          width: 50,
                          child:
                              Image(image: AssetImage('./assets/ic_mail.png')),
                        ),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6)))),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Hãng xe không được để trống";
                      }
                      if (text.length < 2) {
                        return "Vui lòng nhập hãng xe hợp lệ";
                      }
                      if (text.length > 49) {
                        return "Hãng xe quá dài vui lòng nhập lại";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    controller: carNumberController,
                    decoration: InputDecoration(
                        labelText: 'Biển số xe',
                        prefixIcon: Container(
                          width: 50,
                          child:
                              Image(image: AssetImage('./assets/ic_mail.png')),
                        ),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6)))),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Biển số xe không được để trống";
                      }
                      if (text.length < 2) {
                        return "Vui lòng nhập biển số xe hợp lệ";
                      }
                      if (text.length > 10) {
                        return "Biển số quá dài vui lòng nhập lại";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    controller: carColorController,
                    decoration: InputDecoration(
                        labelText: 'Màu xe',
                        prefixIcon: Container(
                          width: 50,
                          child:
                              Image(image: AssetImage('./assets/ic_mail.png')),
                        ),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6)))),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Màu xe không được để trống";
                      }
                      if (text.length < 2) {
                        return "Vui lòng nhập màu hợp lệ";
                      }
                      if (text.length > 49) {
                        return "Màu quá dài vui lòng nhập lại";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                      hintText: "Chọn loại xe",
                      prefixIcon: Icon(
                        Icons.car_crash,
                        color: Colors.black,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ))),
                  items: carTypes.map((car) {
                    return DropdownMenuItem(
                      child: Text(
                        car,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      value: car,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCarType = newValue.toString();
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        _register();
                      },
                      child: Text(
                        'Đăng ký phương tiện',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xff3277D8)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(6))))),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
