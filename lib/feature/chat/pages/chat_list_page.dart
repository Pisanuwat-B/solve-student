import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/chat/widgets/chat_order_card.dart';
import 'package:solve_student/feature/chat/service/chat_provider.dart';
import 'package:solve_student/widgets/dialogs.dart';
import 'package:solve_student/widgets/sizer.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // bool _isSearching = false;
  late AuthProvider auth;
  late ChatProvider chat;
  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    chat = Provider.of<ChatProvider>(context, listen: false);
    auth.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if (auth.firebaseAuth.currentUser != null) {
        if (message.toString().contains('resume')) {
          auth.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          auth.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chat.init(auth: auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          return Future.value(false);
          // if (_isSearching) {
          //   setState(() {
          //     _isSearching = !_isSearching;
          //   });
          //   return Future.value(false);
          // } else {
          //   return Future.value(true);
          // }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'แชท',
              style: TextStyle(
                color: appTextPrimaryColor,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Consumer<ChatProvider>(builder: (context, con, _) {
                  return StreamBuilder(
                    stream: con.getMyChat(auth.uid ?? ""),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                              child: CircularProgressIndicator());
                        case ConnectionState.active:
                        case ConnectionState.done:
                          List<String> chatList = snapshot.data?.docs
                                  .map<String>((e) => e.id)
                                  .toList() ??
                              [];
                          if (chatList.isNotEmpty) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: chatList.length,
                                padding: EdgeInsets.only(
                                    top: Sizer(context).h * .01),
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  String onlyId = chatList[index];
                                  return FutureBuilder(
                                      future: con.getChatInfoV2(onlyId),
                                      builder: (context, snap) {
                                        try {
                                          ChatModel only = snap.data!;
                                          return ChatOrderCard(only);
                                        } catch (e) {
                                          return const SizedBox();
                                        }
                                      });
                                });
                          } else if (chatList.isEmpty) {
                            return const Center(
                              child: Text('No Chat Found!!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                          return loadingWidget(context, 'Loading..');
                      }
                    },
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox loadingWidget(BuildContext context, String text) {
    return SizedBox(
      width: Sizer(context).w,
      height: Sizer(context).h * 0.8,
      child: Center(
        child: Text(text, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
