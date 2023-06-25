import 'package:flutter/material.dart';
import 'package:logisticx_datn_driver/global/global.dart';
import 'package:logisticx_datn_driver/infoHandler/app_info.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RatingsTabPage extends StatefulWidget {
  @override
  State<RatingsTabPage> createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  double ratingsNumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getRatingsNumber() {
    setState(() {
      ratingsNumber = double.parse(
          Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle() {
    if (ratingsNumber >= 0) {
      setState(() {
        titleStarsRating = "Rất tệ";
      });
    }
    if (ratingsNumber >= 1) {
      setState(() {
        titleStarsRating = "Tệ";
      });
    }
    if (ratingsNumber >= 2) {
      setState(() {
        titleStarsRating = "Bình thường";
      });
    }
    if (ratingsNumber >= 3) {
      setState(() {
        titleStarsRating = "Tốt";
      });
    }
    if (ratingsNumber >= 4) {
      setState(() {
        titleStarsRating = "Rất tốt";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 22,
              ),
              Text(
                "Đánh giá của bạn",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SmoothStarRating(
                rating: ratingsNumber,
                allowHalfRating: true,
                starCount: 5,
                color: Colors.blue[400],
                borderColor: Colors.blue,
                size: 46,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                titleStarsRating,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
