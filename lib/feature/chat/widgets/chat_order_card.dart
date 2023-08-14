import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/chat/models/message.dart';
import 'package:solve_student/feature/chat/pages/chat_room_page.dart';
import 'package:solve_student/feature/chat/service/chat_provider.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';

class ChatOrderCard extends StatefulWidget {
  const ChatOrderCard(this.chat, {super.key});
  final ChatModel chat;
  @override
  State<ChatOrderCard> createState() => _ChatOrderCardState();
}

class _ChatOrderCardState extends State<ChatOrderCard> {
  Message? _message;
  late AuthProvider auth;
  late ChatProvider chat;

  setChatInfo() {}

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    chat = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chat.init(auth: auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: chat.getOrderInfo(widget.chat.chatId ?? ""),
      builder: (context, snapshot1) {
        try {
          if (snapshot1.hasData) {
            OrderClassModel order = snapshot1.data!.keys.first;
            UserModel student = snapshot1.data!.values.first;
            return Card(
              margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              // color: Colors.blue.shade100,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomPage(
                          chat: widget.chat,
                          order: order,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Builder(builder: (context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(500),
                          child: CachedNetworkImage(
                            width: 50,
                            height: 50,
                            imageUrl: student.image ?? "",
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person)),
                          ),
                        );
                      }),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("class : ${order.title ?? ""}"),
                            StreamBuilder(
                              stream:
                                  chat.getLastMessage(widget.chat.chatId ?? ""),
                              builder: (context, snapshot) {
                                final data = snapshot.data?.docs;
                                final list = data
                                        ?.map((e) => Message.fromJson(e.data()))
                                        .toList() ??
                                    [];
                                if (list.isNotEmpty) _message = list[0];
                                if (_message?.type == Type.image) {
                                  return const Text("รูปภาพ");
                                }
                                return Text("${_message?.msg ?? ""} ");
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return SizedBox();
        } catch (e) {
          return Card(
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            // color: Colors.blue.shade100,
            elevation: 0.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Chat ${widget.chat.chatId}"),
                        Text("Error Data.. "),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      chat.deleteChatInfo(widget.chat.chatId ?? "");
                      setState(() {});
                    },
                    onDoubleTap: () {},
                    child: Container(
                      width: 50,
                      child: Text(
                        "ลบห้องแชทนี้",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
