import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/chat/pages/chat_room_page.dart';
import 'package:solve_student/feature/chat/service/chat_provider.dart';
import 'package:solve_student/feature/class/models/class_model.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:solve_student/feature/order/service/order_mock_provider.dart';
import 'package:solve_student/widgets/sizer.dart';

import '../../calendar/widgets/sizebox.dart';

class ClassDetailPage extends StatefulWidget {
  ClassDetailPage({
    super.key,
    required this.classDetail,
    required this.user,
  });
  ClassModel classDetail;
  UserModel user;
  @override
  State<ClassDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<ClassDetailPage> {
  late AuthProvider auth;
  late OrderMockProvider order;
  late ChatProvider chat;
  RoleType me = RoleType.student;
  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    order = Provider.of<OrderMockProvider>(context, listen: false);
    chat = Provider.of<ChatProvider>(context, listen: false);
    me = auth.user!.getRoleType();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      order.init(auth: auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "รายละเอียดคอร์ส",
          style: TextStyle(
            color: appTextPrimaryColor,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: Sizer(context).w,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Sizer(context).w,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  child: Image.network(
                    widget.classDetail.image ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.classDetail.name ?? "",
                            style: const TextStyle(
                              color: appTextPrimaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            OrderClassModel orderNew =
                                await order.createOrder(widget.classDetail);
                            // log("message ${orderNew.id}");
                            // //-----
                            ChatModel? data =
                                await order.createChat(orderNew, widget.user);
                            var route = MaterialPageRoute(
                              builder: (_) => ChatRoomPage(
                                chat: data!,
                                order: orderNew,
                              ),
                            );
                            Navigator.push(context, route);
                          },
                          onDoubleTap: () {},
                          child: Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "แชท",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    S.h(10),
                    Row(
                      children: [
                        Icon(
                          Icons.money,
                          color: greyColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.classDetail.price ?? "",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    S.h(10),
                    // Text(
                    //   "UUID: 00000001",
                    //   style: TextStyle(
                    //     color: greyColor,
                    //     fontSize: 15,
                    //   ),
                    // ),
                    // Text(
                    //   widget.classDetail.detail ?? "",
                    //   style: TextStyle(
                    //     color: appTextPrimaryColor,
                    //     fontSize: 15,
                    //   ),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            widget.classDetail.schoolSubject ?? "",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        S.w(4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            widget.classDetail.classLevel ?? "",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     const Icon(Icons.account_circle_outlined),
                    //     Container(
                    //       height: 30,
                    //       child: const VerticalDivider(color: Colors.black),
                    //     ),
                    //     starRateFromNumWidget(4),
                    //   ],
                    // ),
                    const SizedBox(height: 15),
                    const Text(
                      "สร้างโดย",
                      style: TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.classDetail.creatorName ?? "",
                      style: TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "รายละเอียด",
                      style: TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.classDetail.detail ?? "",
                      style: TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: Sizer(context).w,
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(5),
                                child: StreamBuilder(
                                    stream: chat.getUserInfo(
                                        "${widget.classDetail.userId}"),
                                    builder: (context, snap) {
                                      final data = snap.data?.docs;
                                      final list = data
                                              ?.map((e) =>
                                                  UserModel.fromJson(e.data()))
                                              .toList() ??
                                          [];
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          list.isNotEmpty
                                              ? list[0].image ?? ""
                                              : "",
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return FittedBox(
                                              child: Image.asset(
                                                "assets/images/image35.png",
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(builder: (context) {
                                    if (me == RoleType.tutor) {
                                      return const Text(
                                        "นักเรียน",
                                        style: TextStyle(
                                          color: appTextPrimaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                    return const Text(
                                      "อาจารย์ผู้สอน",
                                      style: TextStyle(
                                        color: appTextPrimaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                  Text(
                                    "${widget.classDetail.creatorName ?? ""} ",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget starRateFromNumWidget(int num) {
    return Container(
      height: 30,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: 5,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (double.parse(index.toString()) < num) {
            return Icon(
              CupertinoIcons.star_fill,
              color: Colors.orange,
              size: 20,
            );
          } else {
            return Icon(
              CupertinoIcons.star,
              color: Colors.grey,
              size: 20,
            );
          }
        },
      ),
    );
  }
}
