// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:slove_student/featureauthentication/models/user_model.dart';
// import 'package:slove_student/featureauthentication/service/auth_provider.dart';
// import 'package:slove_student/featureconstants/color_constants.dart';
// import 'package:slove_student/feature/chat2/models/chat_model.dart';
// import 'package:slove_student/feature/chat2/pages/chat_room_page.dart';
// import 'package:slove_student/feature/order_mock/model/order_mock_model.dart';
// import 'package:slove_student/feature/order_mock/service/order_mock_provider.dart';
// import 'package:slove_student/featurewidgets/sizer.dart';

// class OrderMockDetailPage extends StatefulWidget {
//   OrderMockDetailPage({
//     super.key,
//     required this.order,
//     required this.user,
//   });
//   OrderClassModel order;
//   UserModel user;
//   @override
//   State<OrderMockDetailPage> createState() => _OrderDetailPageState();
// }

// class _OrderDetailPageState extends State<OrderMockDetailPage> {
//   late AuthProvider auth;
//   late OrderMockProvider order;
//   @override
//   void initState() {
//     super.initState();
//     auth = Provider.of<AuthProvider>(context, listen: false);
//     order = Provider.of<OrderMockProvider>(context, listen: false);
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       order.init(auth: auth);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Course Detail",
//           style: TextStyle(
//             color: appTextPrimaryColor,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.keyboard_arrow_left,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: Container(
//         width: Sizer(context).w,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: Sizer(context).w,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Expanded(
//                   flex: 5,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.network(
//                       "",
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return const Center(
//                           child: Icon(
//                             Icons.image,
//                             size: 50,
//                             color: Colors.grey,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             widget.order.title ?? "",
//                             style: TextStyle(
//                               color: appTextPrimaryColor,
//                               fontSize: 18,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () async {
//                             ChatModel? data = await order.createChat(
//                                 widget.order, widget.user);
//                             var route = MaterialPageRoute(
//                               builder: (_) => ChatRoomPage(
//                                 chat: data!,
//                                 order: widget.order,
//                               ),
//                             );
//                             Navigator.push(context, route);
//                           },
//                           child: Container(
//                             width: 100,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: ColorConstants.primaryColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             alignment: Alignment.center,
//                             child: Text(
//                               "แชท",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.money,
//                           color: ColorConstants.greyColor,
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           "1,200",
//                           style: TextStyle(
//                             color: ColorConstants.primaryColor,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       ],
//                     ),
//                     Text(
//                       "UUID: 00000001",
//                       style: TextStyle(
//                         color: ColorConstants.greyColor,
//                         fontSize: 15,
//                       ),
//                     ),
//                     Text(
//                       "Learn to evaluate the quality of UX+ UI design of any kind of app, website or enterprise software system.",
//                       style: TextStyle(
//                         color: appTextPrimaryColor,
//                         fontSize: 15,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Row(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
//                           padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
//                           child: Text(
//                             "คณิตศาสตร์",
//                             style: TextStyle(
//                               fontSize: 15,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
//                           child: Text(
//                             "มัธยม 4",
//                             style: TextStyle(
//                               fontSize: 15,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
