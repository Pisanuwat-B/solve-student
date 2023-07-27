import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:slove_student/authentication/models/user_model.dart';
import 'package:slove_student/authentication/service/auth_provider.dart';
import 'package:slove_student/constants/school_subject_constants.dart';
import 'package:slove_student/feature/class/models/class_model.dart';
import 'package:slove_student/feature/class/models/filter_class_model.dart';
import 'package:slove_student/feature/class/pages/class_detail_page.dart';
import 'package:slove_student/feature/class/services/class_provider.dart';
import 'package:slove_student/feature/class/widgets/build_card_class_body_widget.dart';
import 'package:slove_student/feature/class/widgets/filter_class_widget.dart';
import 'package:slove_student/widgets/date_time_format_util.dart';
import 'package:slove_student/widgets/sizer.dart';

class FindClassPage extends StatefulWidget {
  FindClassPage({
    super.key,
    this.filterInit = false,
    this.filSubject,
    this.filterClass,
  });
  bool filterInit;
  String? filSubject;
  String? filterClass;
  @override
  State<FindClassPage> createState() => _FindClassPageState();
}

class _FindClassPageState extends State<FindClassPage> {
  AuthProvider? authProvider;
  ClassProvider? classProvider;

  // String selectClass = "วิชาคณิตศาสตร์";
  int count = 0;
  final txtSearchName = TextEditingController();
  String selectClass = SchoolSubJectConstants.schoolSubJectFilterList.first;
  String selectClassLevel = SchoolSubJectConstants.schoolFilterClassLevel.first;
  String startDate = "";
  String startTime = "";

  Size size = const Size(0, 0);

  List<ClassModel> searchClassList = [];
  int currentPage = 0;
  int totalPage = 0;
  int limit = 4;

  init() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      classProvider = Provider.of<ClassProvider>(context, listen: false);
      selectClassLevel = authProvider!.user!.classLevel == ""
          ? SchoolSubJectConstants.schoolFilterClassLevel.first
          : authProvider!.user!.classLevel!;
      initSearchClassList();
      await checkInitFliter();
      setState(() {});
    });
  }

  checkInitFliter() {
    if (widget.filterInit) {
      selectClass = widget.filSubject ??
          SchoolSubJectConstants.schoolSubJectFilterList.first;
      selectClassLevel =
          widget.filterClass ?? SchoolSubJectConstants.schoolClassLevel.first;
      setState(() {});
    }
  }

  initSearchClassList() async {
    searchClassList = [];
    var getItemList = await classProvider?.firestore
        .collection(authProvider?.user!.role! == "tutor"
            ? 'class_study'
            : 'class_tutor')
        .get();

    var filterList = onFilter(getItemList!.docs);
    if (filterList.isNotEmpty) {
      if (filterList.length > limit) {
        totalPage = filterList.length ~/ limit;
        if (filterList.length % limit != 0) {
          totalPage = (filterList.length ~/ limit) + 1;
        }
      } else {
        totalPage = 1;
      }
      for (int i = 0; i < filterList.length; i++) {
        if (i >= ((limit * (currentPage + 1)) - limit) &&
            i <= (limit * (currentPage + 1) - 1)) {
          ClassModel item = ClassModel.fromJson(filterList[i].data());
          searchClassList.add(item);
        }
      }
    }
    setState(() {});
  }

  // List<QueryDocumentSnapshot<Map<String, dynamic>>> getDataFilter(
  //     List<QueryDocumentSnapshot<Map<String, dynamic>>> dataList) {
  //   List<QueryDocumentSnapshot<Map<String, dynamic>>> result = [];
  //   List<QueryDocumentSnapshot<Map<String, dynamic>>> getItemList = [];
  //   getItemList = onFilter(dataList);
  //   // result = getItemList;

  //   // print('aaaa: ${getItemList.length}');
  //   for (int i = 0; i < getItemList.length; i++) {
  //     // print('xxx: ${getItemList[i]["id"]}');
  //     // i>=(limit-currentPage)-limit && i<=(limit*currentPage-1)
  //     if (i >= ((2 * 2) - 2) && i <= (2 * 2 - 1)) {
  //       // print('object: $i');
  //       result.add(getItemList[i]);
  //     }
  //   }

  //   return result;
  // }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> onFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> dataList) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> result = [];
    if (selectClass != "ทั้งหมด") {
      if (selectClassLevel != "ทั้งหมด") {
        result = dataList.where((el1) {
          var cData = el1.data();
          // DateTime sDate = DateTime.parse(cData["startDate"]);
          return cData["schoolSubject"] == selectClass &&
              cData["name"].toString().toLowerCase().startsWith(
                    txtSearchName.text.toLowerCase(),
                  ) &&
              (cData["classLevel"] == selectClassLevel) &&
              (cData["isBooking"] == null || cData["isBooking"] == 0);
        }).toList();
      } else {
        result = dataList.where((el1) {
          var cData = el1.data();
          // DateTime sDate = DateTime.parse(cData["startDate"]);
          return cData["schoolSubject"] == selectClass &&
              cData["name"].toString().toLowerCase().startsWith(
                    txtSearchName.text.toLowerCase(),
                  ) &&
              // (cData["classLevel"] == selectClassLevel) &&
              (cData["isBooking"] == null || cData["isBooking"] == 0);
        }).toList();
      }
    } else {
      if (selectClassLevel != "ทั้งหมด") {
        result = dataList.where((el1) {
          var cData = el1.data();
          return cData["name"].toString().toLowerCase().startsWith(
                    txtSearchName.text.toLowerCase(),
                  ) &&
              (cData["classLevel"] == selectClassLevel) &&
              (cData["isBooking"] == null || cData["isBooking"] == 0);
        }).toList();
      } else {
        result = dataList.where((el1) {
          var cData = el1.data();
          return cData["name"].toString().toLowerCase().startsWith(
                    txtSearchName.text.toLowerCase(),
                  ) &&
              // (cData["classLevel"] == selectClassLevel) &&
              (cData["isBooking"] == null || cData["isBooking"] == 0);
        }).toList();
      }
    }

    if (startDate != "") {
      result = result.where((el1) {
        var cData = el1.data();
        String d1 = DateTime.parse(startDate).date();
        String d2 = DateTime.parse(cData["startDate"]).date();
        return d1.compareTo(d2) == 0 || d1.compareTo(d2) == -1;
      }).toList();
    }
    if (startTime != "") {
      result = result.where((el1) {
        var cData = el1.data();
        String d1 = startTime;
        String d2 = DateFormat(
          'HH:mm',
        ).format(DateTime.parse(cData["startTime"]));
        return d1.compareTo(d2) == 0 || d1.compareTo(d2) == -1;
      }).toList();
    }
    // result.sort((a,b)=> a);
    return result;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              authProvider?.user!.getRoleType() == RoleType.tutor
                  ? 'ค้นหานักเรียน'
                  : 'ค้นหาติวเตอร์',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 35,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtSearchName,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 0),
                        enabledBorder: borderStyle(),
                        focusedBorder: borderStyle(),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 30, maxWidth: 30),
                        // icon: Icon(Icons.search),
                        hintText:
                            "ค้นหา.. (ชื่อคอร์ส ชื่อ${authProvider?.user!.getRoleType() == RoleType.tutor ? 'นักเรียน' : 'ติวเตอร์'})",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        initSearchClassList();
                      },
                      onFieldSubmitted: (value) {
                        setState(() {});
                        initSearchClassList();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.grey, width: 1)),
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return FilterClassWidget(
                                data: FilterClassModel(
                                    schoolSubject: selectClass,
                                    classLevel: selectClassLevel,
                                    startDate: startDate,
                                    startTime: startTime),
                              );
                            },
                          ).then((value) {
                            if (value != null) {
                              FilterClassModel item = value;
                              selectClass = item.schoolSubject;
                              selectClassLevel = item.classLevel;
                              startDate = item.startDate;
                              startTime = item.startTime;
                              setState(() {});
                              initSearchClassList();
                            }
                            //
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.filter_list,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Filter',
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 22,
            ),

            Builder(builder: (context) {
              if (searchClassList.isNotEmpty) {
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Sizer(context).w <= 600 ? 1 : 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 25,
                  ),
                  itemCount: searchClassList.length,
                  itemBuilder: (context, index) {
                    ClassModel item = searchClassList[index];
                    return BuildCardClassBodyWidget(
                      item,
                      (item) {
                        var route = MaterialPageRoute(
                            builder: (context) => ClassDetailPage(
                                  classDetail: item,
                                  user: authProvider!.user!,
                                ));
                        Navigator.push(context, route);
                      },
                    );
                  },
                );
              } else if (searchClassList.isEmpty) {
                return Center(child: Text("ไม่พบรายการที่ค้นหา"));
              }
              return Center(child: Text("Loading..."));
            }),
            // StreamBuilder(
            //   stream: classProvider?.getAllClass(
            //       isTutor: authProvider?.user!.role! == "tutor" ? true : false),
            //   // classProvider?.firestore.collection('class_study').snapshots(),
            //   builder: (context, snapshot) {
            //     if (!snapshot.hasData) {
            //       return const Center(
            //         child: CircularProgressIndicator(),
            //       );
            //     }
            //     var rawData = snapshot.data!.docs;
            //     var rawDataList = [];
            //     List<ClassModel> dataList = [];
            //     if (rawData.isNotEmpty) {
            //       rawDataList = getDataFilter(rawData);
            //     }
            //     if (rawDataList.isNotEmpty) {
            //       dataList = List<ClassModel>.from(
            //           rawDataList.map((e) => ClassModel.fromJson(e.data())));

            //       print('=========: ${rawDataList.length} :=========');

            //       // dataList.sort((a, b) => a.classLevel!.compareTo(b.classLevel!));
            //       dataList.sort((a, b) {
            //         DateTime d1 = DateTime(a.startDate!.year, a.startDate!.month,
            //             a.startDate!.day, a.startTime!.hour, a.startTime!.hour);
            //         DateTime d2 = DateTime(b.startDate!.year, b.startDate!.month,
            //             b.startDate!.day, b.startTime!.hour, b.startTime!.hour);
            //         return d1.compareTo(d2);
            //       });
            //     }
            //     count = dataList.length;
            //     return (snapshot.connectionState == ConnectionState.waiting)
            //         ? const Center(
            //             child: CircularProgressIndicator(),
            //           )
            //         : GridView.builder(
            //             physics: const NeverScrollableScrollPhysics(),
            //             shrinkWrap: true,
            //             itemCount: dataList.length,
            //             gridDelegate:
            //                 const SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 2,
            //               crossAxisSpacing: 15,
            //               mainAxisSpacing: 25,
            //               // mainAxisExtent: 300
            //             ),
            //             itemBuilder: (context, index) {
            //               ClassModel item = dataList[index];
            //               // print('object: $index: ${item.image}');
            //               return buildCardClassBody(
            //                 item,
            //                 (item) {
            //                   // Navigator.push(
            //                   //   context,
            //                   //   MaterialPageRoute(
            //                   //       builder: (context) => CreateClassPage(
            //                   //             classModelEdit: item,
            //                   //           )),
            //                   // );
            //                 },
            //               );
            //             },
            //           );
            //   },
            // ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        color: Colors.white,
        child: Builder(builder: (context) {
          if (searchClassList.isNotEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: getMaxWidth(totalPage)),
                  child: NumberPaginator(
                    // by default, the paginator shows numbers as center content
                    initialPage: currentPage,
                    numberPages: totalPage,
                    onPageChange: (int index) {
                      setState(() {
                        currentPage = index;
                        initSearchClassList();
                        // print('=================: ${currentPage}');
                      });
                    },
                    config: NumberPaginatorUIConfig(
                        buttonSelectedBackgroundColor: Colors.green,
                        // buttonSelectedForegroundColor: Colors.blue,
                        buttonShape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(5)),
                        mode: ContentDisplayMode.numbers,
                        mainAxisAlignment: MainAxisAlignment.center),
                    // contentBuilder: (index) {
                    //   return Container(child: Text('${index+1}'),);
                    // },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        }),
      ),
    );
  }

  OutlineInputBorder borderStyle() => OutlineInputBorder(
          borderSide: BorderSide(
        color: Colors.grey.shade400,
      ));

  double getMaxWidth(int totalPage) {
    double result = 350;
    if (totalPage <= 1) {
      print('aaaaa');
      result = 150;
    } else if (totalPage > 1 && totalPage <= 3) {
      print('bbbbb');
      result = 250;
    }
    return result;
  }
}
