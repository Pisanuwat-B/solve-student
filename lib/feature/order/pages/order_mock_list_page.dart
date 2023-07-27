// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:slove_student/featureauthentication/service/auth_provider.dart';
// import 'package:slove_student/featureconstants/color_constants.dart';
// import 'package:slove_student/feature/chat2/service/chat_provider.dart';
// import 'package:slove_student/feature/order_mock/model/order_mock_model.dart';
// import 'package:slove_student/feature/order_mock/pages/order_mock_detail_page.dart';
// import 'package:slove_student/feature/order_mock/service/order_mock_provider.dart';
// import 'package:slove_student/featurewidgets/sizer.dart';

// class OrderMockListPage extends StatefulWidget {
//   const OrderMockListPage({super.key});

//   @override
//   State<OrderMockListPage> createState() => _OrderMockListState();
// }

// class _OrderMockListState extends State<OrderMockListPage> {
//   late AuthProvider auth;
//   late OrderMockProvider order;
//   List<OrderClassModel> _list = [];
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
//         title: const Text(
//           "ติวเตอร์",
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
//       body: SafeArea(
//         child: Container(
//           width: Sizer(context).w,
//           height: Sizer(context).h,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: StreamBuilder(
//                   stream: order.getAllOrder(),
//                   builder: (context, snapshot) {
//                     switch (snapshot.connectionState) {
//                       case ConnectionState.waiting:
//                       case ConnectionState.none:
//                         return const SizedBox();
//                       case ConnectionState.active:
//                       case ConnectionState.done:
//                         final data = snapshot.data?.docs;
//                         _list = data
//                                 ?.map((e) => OrderClassModel.fromJson(e.data()))
//                                 .toList() ??
//                             [];

//                         if (_list.isNotEmpty) {
//                           log("message : ${_list.length}");
//                           return ListView.builder(
//                               itemCount: _list.length,
//                               physics: const BouncingScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 OrderClassModel only = _list[index];
//                                 return GestureDetector(
//                                   onTap: () async {
//                                     // await order.createChat(only, auth.user!);
//                                     var route = MaterialPageRoute(
//                                       builder: (context) => OrderMockDetailPage(
//                                         order: only,
//                                         user: auth.user!,
//                                       ),
//                                     );
//                                     Navigator.push(context, route);
//                                   },
//                                   child: Card(
//                                     child: Container(
//                                       height: 50,
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "order id :${only.id}",
//                                           ),
//                                           Text(
//                                             "tutor :${only.tutorId}",
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               });
//                         } else {
//                           return const Center(
//                             child: Text('Empty Order',
//                                 style: TextStyle(fontSize: 20)),
//                           );
//                         }
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       // floatingActionButton: Padding(
//       //   padding: const EdgeInsets.only(bottom: 10),
//       //   child: Column(
//       //     mainAxisSize: MainAxisSize.min,
//       //     children: [
//       //       FloatingActionButton(
//       //         onPressed: () async {
//       //           await order.createOrder();
//       //           // // 50c3094a-557a-4713-80ae-abf54606a078
//       //           // await chat.orderFirstMessage(
//       //           //   auth.user!,
//       //           //   "b574c661-50f6-47fc-a6f7-c586c0e5aad4",
//       //           //   "test",
//       //           //   msg.Type.text,
//       //           // );
//       //         },
//       //         child: const Icon(
//       //           Icons.add,
//       //         ),
//       //       ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }
// }
