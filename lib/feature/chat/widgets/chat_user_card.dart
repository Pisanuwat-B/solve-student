// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:solve_student/featureauthentication/models/user_model.dart';
// import 'package:solve_student/featureauthentication/service/auth_provider.dart';
// import 'package:solve_student/feature/chat/widgets/profile_dialog.dart';
// import 'package:solve_student/featureutils/my_date_util.dart';
// import 'package:solve_student/feature/chat/models/message.dart';
// import 'package:solve_student/feature/chat/pages/chat_room_page.dart';
// import 'package:solve_student/feature/chat/service/chat_provider.dart';
// import 'package:solve_student/featurewidgets/sizer.dart';

// class ChatUserCard extends StatefulWidget {
//   final UserModel user;
//   const ChatUserCard({super.key, required this.user});

//   @override
//   State<ChatUserCard> createState() => _ChatUserCardState();
// }

// class _ChatUserCardState extends State<ChatUserCard> {
//   //last message info (if null --> no message)
//   Message? _message;
//   @override
//   void initState() {
//     super.initState();
//     auth = Provider.of<AuthProvider>(context, listen: false);
//     chat = Provider.of<ChatProvider>(context, listen: false);
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       chat.init(auth: auth);
//     });
//   }

//   late AuthProvider auth;
//   late ChatProvider chat;
//   @override
//   Widget build(BuildContext context) {
//     Sizer mq = Sizer(context);
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: mq.w! * .04, vertical: 4),
//       // color: Colors.blue.shade100,
//       elevation: 0.5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: InkWell(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => ChatRoomPage(user: widget.user)));
//           },
//           child: StreamBuilder(
//             stream: chat.getLastMessage(widget.user),
//             builder: (context, snapshot) {
//               final data = snapshot.data?.docs;
//               final list =
//                   data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
//               if (list.isNotEmpty) _message = list[0];
//               return ListTile(
//                 leading: InkWell(
//                   onTap: () {
//                     showDialog(
//                         context: context,
//                         builder: (_) => ProfileDialog(user: widget.user));
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(mq.h! * .03),
//                     child: CachedNetworkImage(
//                       width: mq.h! * .055,
//                       height: mq.h! * .055,
//                       imageUrl: widget.user.image ?? "",
//                       errorWidget: (context, url, error) => const CircleAvatar(
//                           child: Icon(CupertinoIcons.person)),
//                     ),
//                   ),
//                 ),
//                 title: Text(widget.user.name ?? ""),
//                 subtitle: Text(
//                     _message != null
//                         ? _message!.type == Type.image
//                             ? 'image'
//                             : _message!.msg
//                         : widget.user.about ?? "",
//                     maxLines: 1),
//                 trailing: _message == null
//                     ? null
//                     : _message!.read.isEmpty && _message!.fromId != auth.uid
//                         ? Container(
//                             width: 15,
//                             height: 15,
//                             decoration: BoxDecoration(
//                                 color: Colors.greenAccent.shade400,
//                                 borderRadius: BorderRadius.circular(10)),
//                           )
//                         : Text(
//                             MyDateUtil.getLastMessageTime(
//                                 context: context, time: _message!.sent),
//                             style: const TextStyle(color: Colors.black54),
//                           ),
//               );
//             },
//           )),
//     );
//   }
// }
