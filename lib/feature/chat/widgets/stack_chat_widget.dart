import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/feature/chat/service/chat_provider.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';

class StackChatWidget extends StatefulWidget {
  StackChatWidget({Key? key, required this.order}) : super(key: key);
  final OrderClassModel order;
  @override
  State<StackChatWidget> createState() => _StackChatWidgetState();
}

class _StackChatWidgetState extends State<StackChatWidget> {
  // ChatModel? data;
  late ChatProvider chat;
  @override
  void initState() {
    chat = Provider.of<ChatProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Text("data"),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: Provider.of<ChatProvider>(context, listen: false)
                .getStackChat("${widget.order.id}"),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const SizedBox();
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  var list = data?.toList() ?? [];
                  if (list.isNotEmpty) {
                    return Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: FittedBox(
                        child: Text(
                          '${list.length} ',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}
