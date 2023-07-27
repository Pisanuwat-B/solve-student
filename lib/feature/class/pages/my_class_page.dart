import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/class/models/class_model.dart';
import 'package:solve_student/feature/class/pages/create_class_page.dart';
import 'package:solve_student/feature/class/services/class_provider.dart';
import 'package:solve_student/feature/class/widgets/build_card_class_body_widget.dart';
import 'package:solve_student/widgets/sizer.dart';

class MyClassPage extends StatefulWidget {
  const MyClassPage({super.key});

  @override
  State<MyClassPage> createState() => _MyClassPageState();
}

class _MyClassPageState extends State<MyClassPage> {
  AuthProvider? authProvider;
  ClassProvider? classProvider;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      classProvider = Provider.of<ClassProvider>(context, listen: false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
                stream: classProvider?.getAllClassById(authProvider!.user!.id!,
                    authProvider?.user!.role! == "tutor" ? true : false),
                builder: (context, snapshot) {
                  try {
                    final List<ClassModel> list = [];

                    if (snapshot.hasData) {
                      final data = snapshot.data?.docs;
                      for (var i in data!) {
                        ClassModel model = ClassModel.fromJson(i.data());
                        list.add(model);
                      }
                    }

                    if (list.isNotEmpty) {
                      list.sort((a, b) {
                        return a.createdAt!
                            .toString()
                            .compareTo(b.createdAt!.toString());
                      });
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: list.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Sizer(context).w <= 600 ? 1 : 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 25,
                          // mainAxisExtent: 300
                        ),
                        itemBuilder: (context, index) {
                          ClassModel item = list[index];

                          return BuildCardClassBodyWidget(
                            item,
                            (item) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateClassPage(
                                          classModelEdit: item,
                                        )),
                              );
                            },
                          );
                        },
                      );
                    } else if (list.isEmpty) {
                      return const Text("No data");
                    }
                    return const Text("Loading...");
                  } catch (e) {
                    return const Text("Error data");
                  }
                }),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
