import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/feature/chat/pages/view_profile_page.dart';
import 'package:solve_student/widgets/sizer.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: Sizer(context).w * .6,
        height: Sizer(context).h * .35,
        child: Stack(
          children: [
            Positioned(
              top: Sizer(context).h * .075,
              left: Sizer(context).w * .1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizer(context).h * .25),
                child: CachedNetworkImage(
                  width: Sizer(context).w * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image ?? "",
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),
            Positioned(
              left: Sizer(context).w * .04,
              top: Sizer(context).h * .02,
              width: Sizer(context).w * .55,
              child: Text(user.name ?? "",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewProfilePage(user: user)));
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(Icons.info_outline,
                    color: Colors.blue, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
