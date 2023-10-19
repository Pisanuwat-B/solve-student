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
          body: SafeArea(
            child: Container(
              height: Sizer(context).h,
              width: Sizer(context).w,
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Container(
                    height: con.replayData?.solvepadHeight ?? 0,
                    width: con.replayData?.solvepadWidth ?? 0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Image.network(
                              "https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/medias%2F3Bt8lonPd8SPqcLmCd3DR3onlln1%2F7nHrkvZwlb1ioATrFQEg%2F7nHrkvZwlb1ioATrFQEg_1690225529939.jpg?alt=media&token=1690225574769"),
                        ),
                        ...con.offsetBuild.map<Widget>((item) {
                          return Positioned(
                            top: item!.dy,
                            left: item.dx,
                            child: Container(
                              height: 20,
                              width: 20,
                              color: Colors.red,
                              alignment: Alignment.center,
                            ),
                          );
                        }).toList(),
                        
                        Builder(builder: (context) {
                          if (con.offsetPlay == null) {
                            return const SizedBox();
                          }
                          return AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            top: con.offsetPlay!.dy,
                            left: con.offsetPlay!.dx,
                            child: Container(
                              color: Colors.cyan,
                              height: 20,
                              width: 20,
                              child: Text("hello "),
                            ),
                          );
                        }),
                        Text("data : ${con.start}, ${con.offsetPlay}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    con.timer!.cancel();
                  },
                  icon: Icon(
                    Icons.pause,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    con.setReplay();
                  },
                  icon: Icon(
                    Icons.play_arrow,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
