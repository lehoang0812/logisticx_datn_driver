// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:logisticx_datn_user/home/index.dart';
// import 'package:logisticx_datn_user/login/index.dart';

// class HomePage extends StatefulWidget {
//   static const String routeName = '/home';

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _homeBloc = HomeBloc(UnHomeState());
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: Text("Chào mừng " "đến với LOGISTICX"),
//         leading: IconButton(
//           icon: Icon(Icons.menu),
//           onPressed: () {
//             scaffoldKey.currentState!.openDrawer();
//           },
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: UserAccountsDrawerHeader(
//                 accountName: Text('huang dz chim to so 1'),
//                 accountEmail: Text('Hoangoku@gmail.com'),
//                 currentAccountPicture: CircleAvatar(
//                   radius: 30,
//                   backgroundImage: NetworkImage(
//                       'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-qx4US34opxS6iWakePxr0y-dWH-oG-fJFoSKGWq2LA&s'),
//                 ),
//               ),
//             ),
//             ListTile(
//               title: Text('Tạo đơn hàng mới'),
//               leading: FaIcon(FontAwesomeIcons.cartPlus),
//               onTap: () {
//                 //handle Drawer item 1 click
//               },
//             ),
//             ListTile(
//               title: Text('Thông tin đơn hàng'),
//               leading: FaIcon(FontAwesomeIcons.cartShopping),
//               onTap: () {
//                 //handle Drawer item 2 click
//               },
//             ),
//             ListTile(
//               title: Text('Quản lý ngân hàng'),
//               leading: FaIcon(FontAwesomeIcons.moneyCheckDollar),
//               onTap: () {
//                 //handle Drawer item 3 click
//               },
//             ),
//             ListTile(
//               title: Text('Quản lý người dùng'),
//               leading: Icon(Icons.person),
//               onTap: () {
//                 //handle Drawer item 4 click
//               },
//             ),
//             ListTile(
//               title: Text('Đăng xuất'),
//               leading: Icon(Icons.logout),
//               onTap: () {
//                 FirebaseAuth.instance.signOut();
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => LoginPage(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: HomeScreen(homeBloc: _homeBloc),
//     );
//   }
// }
