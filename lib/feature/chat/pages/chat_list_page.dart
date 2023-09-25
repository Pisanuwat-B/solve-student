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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer<ChatProvider>(builder: (context, con, _) {
                    try {
                      return StreamBuilder(
                        stream: con.getMyOrderChat(auth.uid ?? ""),
                        builder: (context, snapshot) {
                          var dataSet =
                              snapshot.data?.docs.map((e) => e.id).toList() ??
                                  [];
                          if (dataSet.isEmpty) {
                            return const Center(
                              child: Text(
                                'No Chat Found!',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());
                            case ConnectionState.active:
                            case ConnectionState.done:
                              if (dataSet.isNotEmpty) {
                                return FutureBuilder(
                                    future: con.getAllChatV2(dataSet),
                                    builder: (context, snap) {
                                      if (snap.data?.isNotEmpty ?? false) {
                                        return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snap.data?.length ?? 0,
                                            padding: EdgeInsets.only(
                                                top: Sizer(context).h * .01),
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              ChatModel only =
                                                  snap.data![index];
                                              return ChatOrderCard(only);
                                            });
                                      } else if (snap.data?.isEmpty ?? false) {
                                        return const Center(
                                          child: Text('No Chat Found!',
                                              style: TextStyle(fontSize: 20)),
                                        );
                                      }
                                      return const Center(
                                        child: Text('',
                                            style: TextStyle(fontSize: 20)),
                                      );
                                    });
                              }
                              return const Center(
                                child: Text('', style: TextStyle(fontSize: 20)),
                              );
                          }
                        },
                      );
                    } catch (e) {
                      return const Center(
                        child:
                            Text('Error data', style: TextStyle(fontSize: 20)),
                      );
                    }
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
