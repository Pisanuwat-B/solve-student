import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/feature/replay/controller/replay_controller.dart';
import 'package:solve_student/widgets/sizer.dart';

class ReplayPage extends StatefulWidget {
  const ReplayPage({super.key});

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  ReplayController? controller;

  @override
  void initState() {
    controller = ReplayController(context);
    controller!.init();
    super.initState();
  }

  final double height = 200;
  final double width = 200;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<ReplayController>(builder: (context, con, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Replay"),
          ),
          body: Container(
            height: Sizer(context).h,
            width: Sizer(context).w,
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  Text("data : ${con.start}, ${con.offsetPlay}"),
                  Builder(builder: (context) {
                    if (con.offsetPlay == null) {
                      return const SizedBox();
                    }
                    return AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      top: con.offsetPlay!.dy - 100,
                      left: con.offsetPlay!.dx - 100,
                      child: Container(
                        color: Colors.cyan,
                        height: 100,
                        width: 100,
                        child: Text("hello "),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
