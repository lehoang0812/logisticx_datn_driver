import 'package:firebase_auth/firebase_auth.dart';
import 'package:logisticx_datn_driver/models/user_model.dart';

import '../models/direction_details_info.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOffAddress = "";
