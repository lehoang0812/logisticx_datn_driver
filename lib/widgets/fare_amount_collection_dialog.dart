import 'package:flutter/material.dart';
import 'package:logisticx_datn_driver/splashScreen/splash_screen.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;

  FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() =>
      _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState
    extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            //Gia don hang
            Text(
              "Giá đơn hàng",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            Text(
              widget.totalFareAmount.toString() + "VNĐ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 50,
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Đây là tổng số tiền của đơn hàng này, vui lòng nhận từ khách hàng",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 2000), () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => SplashScreen()));
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Đã nhận tiền",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.totalFareAmount.toString() + "VNĐ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
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
