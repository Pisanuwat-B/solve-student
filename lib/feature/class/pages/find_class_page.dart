import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/school_subject_constants.dart';
import 'package:solve_student/feature/class/models/class_model.dart';
import 'package:solve_student/feature/class/models/filter_class_model.dart';
import 'package:solve_student/feature/class/pages/class_detail_page.dart';
import 'package:solve_student/feature/class/services/class_provider.dart';
import 'package:solve_student/feature/class/widgets/build_card_class_body_widget.dart';
import 'package:solve_student/feature/class/widgets/filter_class_widget.dart';
import 'package:solve_student/widgets/date_time_format_util.dart';
import 'package:solve_student/widgets/sizer.dart';

import '../../calendar/helper/utility_helper.dart';

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
  static final _util = UtilityHelper();
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
      await checkInitFilter();
      setState(() {});
    });
  }

  checkInitFilter() {
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width > 480 ? 40 : 20),
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey, width: 1)),
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
                      child: const Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Filter',
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
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
                            ),
                          );
                          Navigator.push(context, route);
                        },
                      );
                    },
                  );
                } else if (searchClassList.isEmpty) {
                  return const Center(child: Text("ไม่พบรายการที่ค้นหา"));
                }
                return const Center(child: Text("Loading..."));
              }),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Builder(builder: (context) {
              if (searchClassList.isNotEmpty) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: getMaxWidth(totalPage)),
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
          const SizedBox(height: 5),
        ],
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
      result = 100;
    } else if (totalPage > 1 && totalPage <= 3) {
      result = 200;
    }
    return result;
  }
}
