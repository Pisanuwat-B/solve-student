import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/chat/models/message.dart';
import 'package:solve_student/feature/chat/service/chat_provider.dart';
import 'package:solve_student/feature/chat/widgets/message_card.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:solve_student/feature/order/pages/payment_page.dart';
import 'package:solve_student/feature/order/service/order_mock_provider.dart';
import 'package:solve_student/widgets/date_until.dart';
import 'package:solve_student/widgets/sizer.dart';

class ChatRoomPage extends StatefulWidget {
  ChatRoomPage({
    super.key,
    required this.chat,
    required this.order,
  });
  final ChatModel chat;
  final OrderClassModel order;
  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  Sizer? mq;
  RoleType me = RoleType.student;
  late AuthProvider auth;
  late ChatProvider chat;
  OrderClassModel? orderDetail;
  getOrderDetail() async {
    try {
      orderDetail =
          await OrderMockProvider().getOrderDetail(widget.order.id ?? "");
      log("orderDetail ${orderDetail?.toJson()}");
      setState(() {});
    } catch (e) {
      log("error : $e");
    }
  }

  init() async {
    await getOrderDetail();
  }

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    chat = Provider.of<ChatProvider>(context, listen: false);
    me = auth.user!.getRoleType();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      chat.init(auth: auth);
      await init();
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = Sizer(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() => _showEmoji = !_showEmoji);
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            // preferredSize: (!widget.order.paymentOn)
            //     ? const Size.fromHeight(70)
            //     : const Size.fromHeight(110),
            child: SafeArea(
              child: AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.transparent,
                ),
                flexibleSpace: Builder(builder: (context) {
                  return _appBar();
                  // if (widget.order.paymentOn) {
                  //   return _appBar();
                  // }
                  // return _appBarMarket();
                }),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          // backgroundColor: const Color.fromARGB(255, 234, 248, 255),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: chat.getAllMessages(widget.chat.chatId ?? ""),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(
                                    top: Sizer(context).h * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                      chat: widget.chat, message: _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('Say Hii! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: Sizer(context).h * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        // bgColor: const Color.fromARGB(255, 234, 248, 255),
                        // columns: 8,
                        // emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    String toUser = widget.order.studentId ?? "";
    if (me == RoleType.student) {
      toUser = widget.order.tutorId ?? "";
    }
    return InkWell(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => ViewProfilePage(user: widget.user)));
      },
      child: StreamBuilder(
        stream: chat.getUserInfo(toUser),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => UserModel.fromJson(e.data())).toList() ?? [];
          return Column(
            children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: list.isNotEmpty
                          ? list[0].image ?? ""
                          : auth.user!.image ?? "",
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.isNotEmpty
                              ? list[0].name ?? ""
                              : auth.user!.name ?? "",
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            color: appTextPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline!
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive ?? "")
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: auth.user!.lastActive ?? ""),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 13,
                            color: appTextPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Builder(builder: (context) {
                  //   if (!widget.order.paymentOn) {
                  //     return const SizedBox();
                  //   }
                  //   if (orderDetail?.paymentStatus == "paid") {
                  //     return Container(
                  //       width: 100,
                  //       margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  //       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  //       alignment: Alignment.center,
                  //       decoration: BoxDecoration(
                  //         color: greyColor2,
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       child: const Text(
                  //         "ชำระเรียบร้อย",
                  //         style: TextStyle(
                  //           fontSize: 15,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     );
                  //   }
                  //   return GestureDetector(
                  //     onTap: () {
                  //       var route = MaterialPageRoute(
                  //         builder: (_) => PaymentPage(
                  //           orderDetailId: widget.order.id ?? "",
                  //         ),
                  //       );
                  //       Navigator.push(context, route).then((value) {
                  //         init();
                  //       });
                  //     },
                  //     child: Container(
                  //       width: 100,
                  //       margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  //       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  //       alignment: Alignment.center,
                  //       decoration: BoxDecoration(
                  //         color: primaryColor,
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       child: const Text(
                  //         "ชำระค่าบริการ",
                  //         style: TextStyle(
                  //           fontSize: 15,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //   );
                  // }),
                ],
              ),
              // Builder(builder: (context) {
              //   if (!widget.order.paymentOn) {
              //     return const SizedBox();
              //   }
              //   return Container(
              //     padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              //     child: Row(
              //       children: [
              //         Expanded(child: SizedBox()),
              //         Column(
              //           crossAxisAlignment: CrossAxisAlignment.end,
              //           children: [
              //             Builder(builder: (context) {
              //               String text = "ยังไม่ชำระเงิน";
              //               if (orderDetail?.paymentStatus == "paid") {
              //                 text = "ชำระเรียบร้อยแล้ว";
              //               }
              //               return Text("สถานะการชำระเงิน : $text");
              //             }),
              //             Text("คอร์สเรียน : ${orderDetail?.title ?? ""}"),
              //           ],
              //         ),
              //       ],
              //     ),
              //   );
              // }),
            ],
          );
        },
      ),
    );
  }

  Widget _appBarMarket() {
    String toUser = widget.order.studentId ?? "";
    if (me == RoleType.student) {
      toUser = widget.order.tutorId ?? "";
    }
    return InkWell(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => ViewProfilePage(user: widget.user)));
      },
      child: StreamBuilder(
        stream: chat.getUserInfo(toUser),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => UserModel.fromJson(e.data())).toList() ?? [];
          return Column(
            children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: list.isNotEmpty
                          ? list[0].image ?? ""
                          : auth.user!.image ?? "",
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.isNotEmpty
                              ? list[0].name ?? ""
                              : auth.user!.name ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: appTextPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline!
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive ?? "")
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: auth.user!.lastActive ?? ""),
                          style: const TextStyle(
                            fontSize: 13,
                            color: appTextPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: Sizer(context).h * .01,
          horizontal: Sizer(context).w * .025),
      decoration: BoxDecoration(
        border: Border.all(
          color: greyColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: greyColor2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: greyColor,
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                      decoration: const InputDecoration(
                        hintText: 'พิมพ์ข้อความ',
                        hintStyle: TextStyle(
                          color: greyColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        log('Image Path: ${i.path}');
                        setState(() => _isUploading = true);
                        await chat.sendChatImage(
                          widget.chat.chatId ?? "",
                          auth.uid ?? "",
                          File(i.path),
                        );
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                      color: greyColor,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() => _isUploading = true);
                        await chat.sendChatImage(
                          widget.chat.chatId ?? "",
                          auth.uid ?? "",
                          File(image.path),
                        );
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: greyColor,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: Sizer(context).w * .02),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  chat.sendFirstMessage(
                    widget.chat.chatId ?? "",
                    widget.chat.tutorId ?? "",
                    _textController.text,
                    Type.text,
                  );
                } else {
                  chat.sendMessage(
                      widget.chat.chatId ?? "",
                      widget.chat.tutorId ?? "",
                      _textController.text,
                      Type.text);
                }

                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.grey,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }
}
