import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/constants/assets_manager.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/market_place/pages/market_course_detail_page.dart';
import 'package:solve_student/feature/market_place/service/market_search_controller.dart';
import 'package:solve_student/widgets/sizer.dart';

class MarketSearchPage extends StatefulWidget {
  MarketSearchPage({
    super.key,
    this.filter = false,
    this.subject,
    this.level,
  });
  bool filter;
  String? subject;
  String? level;
  @override
  State<MarketSearchPage> createState() => _MarketSearchPageState();
}

class _MarketSearchPageState extends State<MarketSearchPage> {
  MarketSearchController? controller;
  @override
  void initState() {
    controller = MarketSearchController(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await controller!.init(
          filter: widget.filter, subject: widget.subject, level: widget.level);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<MarketSearchController>(builder: (context, con, _) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "ค้นหาคอร์สเรียน ",
                style: TextStyle(
                  color: appTextPrimaryColor,
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.black,
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // height: 50,
                      child: TextFormField(
                        controller: con.courseNameSearch,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "ชื่อคอร์ส",
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          con.searchCourseName(value);
                        },
                        onChanged: (value) {
                          con.searchCourseName(value);
                        },
                        onEditingComplete: () =>
                            FocusScope.of(context).unfocus(),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณาระบุ";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<Map<String, String>>(
                              value: con.levelSelected,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              elevation: 1,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: "NotoSans",
                              ),
                              hint: const Text("ชั้นปี"),
                              underline: Container(
                                height: 1,
                                color: Colors.transparent,
                              ),
                              onChanged: (Map<String, String>? value) {
                                con.setLevelSelected(value);
                              },
                              items: con.levelList
                                  .map<DropdownMenuItem<Map<String, String>>>(
                                      (Map<String, String> value) {
                                return DropdownMenuItem<Map<String, String>>(
                                  value: value,
                                  child: Text(value.values.first),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<Map<String, String>>(
                              value: con.subjectSelected,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              elevation: 1,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: "NotoSans",
                              ),
                              hint: const Text("วิชาเรียน"),
                              underline: Container(
                                height: 1,
                                color: Colors.transparent,
                              ),
                              onChanged: (Map<String, String>? value) {
                                con.setSubjectSelected(value);
                              },
                              items: con.subjectList
                                  .map<DropdownMenuItem<Map<String, String>>>(
                                      (Map<String, String> value) {
                                return DropdownMenuItem<Map<String, String>>(
                                  value: value,
                                  child: Text(value.values.first),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            con.clearFilter();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "คอร์สเรียน",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Builder(builder: (context) {
                      if (con.isLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text("กำลังโหลด..."),
                            ],
                          ),
                        );
                      } else if (con.courseSearch.isEmpty &&
                          con.courseList.isEmpty) {
                        return Container(
                          width: Sizer(context).w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: Sizer(context).h * 0.2,
                              ),
                              Icon(
                                CupertinoIcons.cube_box,
                                size: 100,
                                color: Colors.grey.shade400,
                              ),
                              Text(
                                "ไม่พบข้อมูล",
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        );
                      } else if (con.courseSearch.isNotEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: con.courseSearch.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            CourseMarketModel only = con.courseSearch[index];
                            return GestureDetector(
                              onTap: () {
                                var route = MaterialPageRoute(
                                    builder: (context) =>
                                        MarketCourseDetailPage(
                                            courseId: only.id ?? ""));
                                Navigator.push(context, route);
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                alignment: Alignment.center,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey.shade50,
                                        ),
                                        height: 150,
                                        width: 200,
                                        child: Builder(builder: (context) {
                                          if (only.thumbnailUrl == null ||
                                              only.thumbnailUrl == "") {
                                            return Image.asset(
                                              ImageAssets.emptyCourse,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.fitHeight,
                                            );
                                          }
                                          return Image.network(
                                            only.thumbnailUrl ?? "",
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                ImageAssets.emptyCourse,
                                                height: 150,
                                                width: 150,
                                                fit: BoxFit.fitHeight,
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${only.courseName ?? ""} ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                          ),
                                          Text(
                                            "${only.detailsText ?? ""}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          tutorWidget(only),
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.account_circle,
                                                color: Colors.grey,
                                              ),
                                              VerticalDivider(),
                                              Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                              ),
                                              Text(
                                                "5",
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text("(0)"),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              subjectWidget(only),
                                              levelWidget(only),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: con.courseList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          CourseMarketModel only = con.courseList[index];
                          return GestureDetector(
                            onTap: () {
                              var route = MaterialPageRoute(
                                  builder: (context) => MarketCourseDetailPage(
                                      courseId: only.id ?? ""));
                              Navigator.push(context, route);
                            },
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey.shade50,
                                      ),
                                      height: 150,
                                      width: 200,
                                      child: Builder(builder: (context) {
                                        if (only.thumbnailUrl == null ||
                                            only.thumbnailUrl == "") {
                                          return Image.asset(
                                            ImageAssets.emptyCourse,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.fitHeight,
                                          );
                                        }
                                        return Image.network(
                                          only.thumbnailUrl ?? "",
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              ImageAssets.emptyCourse,
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.fitHeight,
                                            );
                                          },
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${only.courseName ?? ""} ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                        ),
                                        Text(
                                          "${only.detailsText ?? ""}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        tutorWidget(only),
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.account_circle,
                                              color: Colors.grey,
                                            ),
                                            VerticalDivider(),
                                            Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                            ),
                                            Text(
                                              "5",
                                              style: TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text("(0)"),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            subjectWidget(only),
                                            levelWidget(only),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget subjectWidget(CourseMarketModel only) {
    return FutureBuilder(
      future: controller!.getSubjectInfo(only.subjectId ?? ""),
      builder: (context, snap) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Text(
            snap.data ?? "",
            style: TextStyle(
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget levelWidget(CourseMarketModel only) {
    return FutureBuilder(
      future: controller!.getLevelInfo(only.levelId ?? ""),
      builder: (context, snap) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Text(
            snap.data ?? "",
            style: TextStyle(
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget tutorWidget(CourseMarketModel only) {
    return FutureBuilder(
      future: controller!.getTutorInfo(only.tutorId ?? ""),
      builder: (context, snap) {
        return Container(
          child: Text(
            snap.data?.name ?? "",
            style: const TextStyle(
              fontSize: 14,
              color: primaryColor,
            ),
          ),
        );
      },
    );
  }
}
