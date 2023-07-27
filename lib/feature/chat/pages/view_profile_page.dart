import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slove_student/authentication/models/user_model.dart';
import 'package:slove_student/widgets/date_until.dart';
import 'package:slove_student/widgets/sizer.dart';

class ViewProfilePage extends StatefulWidget {
  final UserModel user;
  const ViewProfilePage({super.key, required this.user});
  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.user.name ?? "")),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizer(context).w * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    width: Sizer(context).w, height: Sizer(context).h * .03),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Sizer(context).h * .1),
                  child: CachedNetworkImage(
                    width: Sizer(context).h * .2,
                    height: Sizer(context).h * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image ?? "",
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(
                        CupertinoIcons.person,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Sizer(context).h * .03),
                Text(
                  widget.user.email ?? "",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: Sizer(context).h * .02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About: ',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                    Text(
                      widget.user.about ?? "",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On: ',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt ?? "",
                  showYear: true),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
