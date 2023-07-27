import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/class/models/class_model.dart';
import 'package:solve_student/feature/class/services/class_provider.dart';
import 'package:solve_student/constants/school_subject_constants.dart';
import 'package:solve_student/widgets/date_time_format_util.dart';

class CreateClassPage extends StatefulWidget {
  const CreateClassPage({super.key, this.classModelEdit});
  final ClassModel? classModelEdit;

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage>
    with TickerProviderStateMixin {
  AuthProvider? authProvider;
  ClassProvider? classProvider;

  String selectClass = SchoolSubJectConstants.schoolSubJectList.first;
  String selectClassLevel = SchoolSubJectConstants.schoolClassLevel.first;

  TextEditingController txtName = TextEditingController();
  TextEditingController txtDetail = TextEditingController();
  TextEditingController txtClassLevel = TextEditingController();
  TextEditingController txtCount = TextEditingController();
  TextEditingController txtPrice = TextEditingController();

  // DateTime selectDateTime = DateTime.now();
  DateTime selectStartDate = DateTime.now().toLocal();
  DateTime selectEndDate = DateTime.now().toLocal();
  DateTime selectStartTime = DateTime.now().toLocal();
  DateTime selectEndTime = DateTime.now().toLocal();

  TextEditingController txtStartDate = TextEditingController();
  TextEditingController txtEndDate = TextEditingController();
  TextEditingController txtStartTime = TextEditingController();
  TextEditingController txtEndTime = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final ImagePicker picker = ImagePicker();
  String? selectImage;
  // String? image;
  // final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  init() {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Provider.of<AuthProvider>(context, listen: false).getSelfInfo();
      if (widget.classModelEdit != null) {
        ClassModel _class = widget.classModelEdit!;
        // authProvider!.user!.id!
        txtName.text = _class.name!;
        selectClass = _class.schoolSubject!;
        selectClassLevel = _class.classLevel!;
        txtDetail.text = _class.detail!;
        txtCount.text = _class.count!;
        txtPrice.text = _class.price!;
        selectStartDate = _class.startDate!;
        txtStartDate.text = selectStartDate.date();
        selectEndDate = _class.endDate!;
        txtEndDate.text = selectEndDate.date();

        selectStartTime = _class.startTime!;
        txtStartTime.text =
            "${selectStartTime.hour.toString().padLeft(2, '0')}:${selectStartTime.minute.toString().padLeft(2, '0')}";
        selectEndTime = _class.endTime!;
        txtEndTime.text =
            "${selectEndTime.hour.toString().padLeft(2, '0')}:${selectEndTime.minute.toString().padLeft(2, '0')}";

        if (_class.image != null) {
          // selectImage = _class.image;
          // print('YYYYYYYY: ${selectImage}');
          // print(
          //     'ZZZZZZZ: ${widget.classModelEdit != null && widget.classModelEdit!.image != null && selectImage == null}');
        }

        // log('XXXXX: ${_class.toJson()}');
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    txtName.dispose();
    txtDetail.dispose();
    txtStartDate.dispose();
    txtEndDate.dispose();
    txtStartTime.dispose();
    txtEndTime.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // authProvider = Provider.of<AuthProvider>(context);
    // classProvider = Provider.of<ClassProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            authProvider?.user!.getRoleType() == RoleType.tutor
                ? 'สร้างประกาศหานักเรียน'
                : 'สร้างประกาศหาติวเตอร์',
            style: const TextStyle(color: appTextPrimaryColor),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: appTextPrimaryColor,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  topicLabel1('สร้างประกาศ'),
                  const SizedBox(
                    height: 10,
                  ),
                  // txtFieldName(
                  //   hint: "ชื่อประกาศ",
                  //   validatorLabel: 'กรุณาระบุชื่อประกาศ',
                  // ),
                  txtFieldBody(
                    txtCtrl: txtName,
                    hint: "ชื่อประกาศ",
                    validatorLabel: 'กรุณาระบุชื่อประกาศ',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  schoolSubjectAndLevelClass(),
                  const SizedBox(
                    height: 26,
                  ),
                  topicLabel1('เพิ่มเติม (ไม่จำเป็น)'),
                  const SizedBox(height: 10),
                  txtDetailBody(),
                  // txtFieldBody(
                  //     txtCtrl: txtName,
                  //     hint: "ชื่อ",
                  //     validatorLabel: 'กรุณาระบุชื่อ'),
                  const SizedBox(
                    height: 15,
                  ),
                  topicLabel1('รายละเอียด'),
                  const SizedBox(
                    height: 10,
                  ),
                  dropdownCount(),
                  const SizedBox(
                    height: 22,
                  ),
                  txtFieldBody(
                    txtCtrl: txtCount,
                    hint: "จำนวน",
                    validatorLabel: 'กรุณาระบุจำนวน',
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  txtFieldBody(
                    txtCtrl: txtPrice,
                    hint: "ราคาต่อชั่วโมง",
                    validatorLabel: 'กรุณาระบุราคา',
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  topicLabel2('* ระยะเวลาเรียน'),
                  Row(
                    children: [
                      Expanded(
                        child: txtFieldBody(
                            txtCtrl: txtStartDate,
                            hint: "เลือกวันที่",
                            validatorLabel: 'กรุณาเลือกวันที่',
                            icon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () async {
                              DateTime? getDate =
                                  await showPopupSelectDate(context);
                              if (getDate != null) {
                                txtStartDate.text = getDate.date();
                                selectStartDate = getDate;
                                setState(() {});
                              }
                            }),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: txtFieldBody(
                            txtCtrl: txtEndDate,
                            hint: "เลือกวันที่",
                            validatorLabel: 'กรุณาเลือกวันที่',
                            icon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () async {
                              DateTime? getDate =
                                  await showPopupSelectDate(context);
                              if (getDate != null) {
                                txtEndDate.text = getDate.date();
                                selectEndDate = getDate;
                                setState(() {});
                              }
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  topicLabel2('* เวลาที่ต้องการเรียน'),
                  Row(
                    children: [
                      Expanded(
                        child: txtFieldBody(
                          txtCtrl: txtStartTime,
                          hint: "เลือกเวลา",
                          validatorLabel: 'กรุณาเลือกเวลา',
                          icon: Icons.timer_outlined,
                          readOnly: true,
                          onTap: () async {
                            TimeOfDay? getTime =
                                await showPopupSelectTime(context);
                            if (getTime != null) {
                              // print('object: ${getTime}');
                              txtStartTime.text =
                                  "${getTime.hour.toString().padLeft(2, '0')}:${getTime.minute.toString().padLeft(2, '0')}";
                              selectStartTime = DateTime(
                                selectEndDate.year,
                                selectEndDate.month,
                                selectEndDate.day,
                                getTime.hour,
                                getTime.minute,
                              );
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: txtFieldBody(
                          txtCtrl: txtEndTime,
                          hint: "เลือกเวลา",
                          validatorLabel: 'กรุณาเลือกเวลา',
                          icon: Icons.timer_outlined,
                          readOnly: true,
                          onTap: () async {
                            TimeOfDay? getTime =
                                await showPopupSelectTime(context);
                            if (getTime != null) {
                              // print('object: ${getTime}');
                              txtEndTime.text =
                                  "${getTime.hour.toString().padLeft(2, '0')}:${getTime.minute.toString().padLeft(2, '0')}";
                              selectEndTime = DateTime(
                                selectEndDate.year,
                                selectEndDate.month,
                                selectEndDate.day,
                                getTime.hour,
                                getTime.minute,
                              );
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 44,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 200,
                      // color: Colors.red,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          children: [
                            SizedBox.expand(
                              child: widget.classModelEdit != null &&
                                      widget.classModelEdit!.image != null &&
                                      selectImage == null
                                  ? Image.network(
                                      widget.classModelEdit!.image!,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    )
                                  : selectImage == null
                                      ? Container(
                                          color: Colors.grey.shade300,
                                          child: Icon(
                                            Icons.image_outlined,
                                            color: Colors.grey.shade400,
                                            size: 80,
                                          ),
                                        )
                                      : Image.file(
                                          File(selectImage!),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                        ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final XFile? getImage = await picker
                                      .pickImage(source: ImageSource.gallery);
                                  if (getImage != null) {
                                    // image = getImage.path;
                                    selectImage = getImage.path;
                                    print(selectImage);
                                    // print('name: ${getImage.name}');
                                    // print(
                                    //     'name 1: ${getImage.name.split('/')}');
                                    // image = File(getImage.path);
                                    setState(() {});
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 44,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ClassModel item = ClassModel(
                            userId: authProvider!.user!.id!,
                            name: txtName.text,
                            schoolSubject: selectClass,
                            classLevel: selectClassLevel,
                            detail: txtDetail.text,
                            count: txtCount.text,
                            price: txtPrice.text,
                            startDate: selectStartDate,
                            endDate: selectEndDate,
                            startTime: selectStartTime,
                            endTime: selectEndTime,
                            // image: widget.classModelEdit.image,
                            creatorName: authProvider!.user!.name,
                            isBooking: 0,
                          );
                          if (widget.classModelEdit != null) {
                            item.id = widget.classModelEdit!.id;
                            item.image = widget.classModelEdit!.image;
                            item.createdAt = widget.classModelEdit!.createdAt;
                          } else {
                            item.image = selectImage;
                            item.createdAt = DateTime.now();
                          }
                          // print('object: ${item.toJson()}');
                          classProvider!
                              .createOrUpdateClass(
                                  item: item,
                                  isTutor: authProvider!.user!.role! == "tutor"
                                      ? true
                                      : false,
                                  isCreate: widget.classModelEdit == null,
                                  isSelectImage: selectImage ?? "")
                              .then((value) {
                            if (value) {
                              Fluttertoast.showToast(msg: 'เพิ่มรายการสำเร็จ');
                              Navigator.of(context).pop();
                            }
                          });
                        }
                      },
                      child: const Text('บันทึก'),
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget topicLabel1(String msg) => Text(
        msg,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  Widget topicLabel2(String msg) => Text(
        msg,
        style: const TextStyle(color: Colors.grey),
      );

  Widget txtFieldName({
    String hint = "",
    String? validatorLabel,
    bool readOnly = false,
    IconData? icon,
    Function()? onTap,
  }) {
    return SizedBox(
      // height: 40,
      child: TextFormField(
        controller: txtName,
        // initialValue: widget.classModelEdit!.name,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.red,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          label: Text(hint),
          hintText: hint,
          // hintStyle: TextStyle(color: Colors.grey.shade200),
          labelStyle: TextStyle(color: Colors.grey.shade400),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
          )),
          focusedBorder: !readOnly
              ? const OutlineInputBorder(
                  borderSide: BorderSide(
                  color: Colors.grey,
                ))
              : const OutlineInputBorder(
                  borderSide: BorderSide(
                  color: Colors.grey,
                )),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.red,
          )),
          icon: icon == null
              ? null
              : Icon(
                  icon,
                  color: Colors.grey,
                ),
        ),
        readOnly: readOnly,
        validator: validatorLabel == null
            ? null
            : (value) {
                if (value == null || value.isEmpty) {
                  return validatorLabel;
                }
                return null;
              },
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );
  }

  Widget schoolSubjectAndLevelClass() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(child: dropdownSchoolSubject()),
          const SizedBox(width: 10),
          Expanded(child: dropdownClassLevel()),
        ],
      ),
    );
  }

  Widget dropdownSchoolSubject() {
    return DropdownButtonFormField(
      icon: const Icon(Icons.arrow_drop_down_outlined),
      isExpanded: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: Colors.grey,
        )),
      ),
      value: selectClass,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาเลือกวิชา';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          selectClass = value!;
        });
      },
      items: SchoolSubJectConstants.schoolSubJectList
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
    // return DropdownButton<String>(
    //   value: selectClass,
    //   icon: const Icon(Icons.arrow_downward),
    //   elevation: 16,
    //   style: const TextStyle(color: Colors.black),
    //   isExpanded: true,
    //   // underline: Container(
    //   //   height: 2,
    //   //   color: Colors.deepPurpleAccent,
    //   // ),
    //   onChanged: (String? value) {
    //     setState(() {
    //       selectClass = value!;
    //     });
    //   },
    //   items: SchoolSubJectConstants.schoolSubJectList
    //       .map<DropdownMenuItem<String>>((String value) {
    //     return DropdownMenuItem<String>(
    //       value: value,
    //       child: Text(value),
    //     );
    //   }).toList(),
    // );
  }

  Widget dropdownClassLevel() {
    return DropdownButtonFormField(
      icon: const Icon(Icons.arrow_drop_down_outlined),
      isExpanded: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: Colors.grey,
        )),
      ),
      value: selectClassLevel,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาเลือกชั้นเรียน';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          selectClassLevel = value!;
        });
      },
      items: SchoolSubJectConstants.schoolClassLevel
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget txtDetailBody() {
    return TextFormField(
      controller: txtDetail,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        filled: true,
        fillColor: Colors.grey.shade300,
        hintText: 'รายละเอียดเพิ่มเติม..',
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
      ),
      maxLines: 3,
      minLines: 3,
      maxLength: 255,
    );
  }

  Widget dropdownCount() {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField(
        icon: const Icon(Icons.arrow_drop_down_outlined),
        isExpanded: true,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey.shade300),
        value: 'จำนวนครั้ง/repeat',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณาเลือกจำนวนครั้ง';
          }
          return null;
        },
        onChanged: (value) {
          // setState(() {
          //   selectClassLevel = value!;
          // });
        },
        items:
            ["จำนวนครั้ง/repeat"].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget txtFieldBody({
    required TextEditingController txtCtrl,
    String hint = "",
    String? validatorLabel,
    bool readOnly = false,
    IconData? icon,
    Function()? onTap,
  }) {
    return SizedBox(
      // height: 40,
      child: TextFormField(
        controller: txtCtrl,
        // initialValue: txtCtrl.text,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          // label: Text(hint),
          hintText: hint,
          // hintStyle: TextStyle(color: Colors.grey.shade200),
          labelStyle: TextStyle(color: Colors.grey.shade400),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
          )),
          focusedBorder: !readOnly
              ? const OutlineInputBorder(
                  borderSide: BorderSide(
                  color: Colors.grey,
                ))
              : const OutlineInputBorder(
                  borderSide: BorderSide(
                  color: Colors.grey,
                )),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.red,
          )),
          icon: icon == null
              ? null
              : Icon(
                  icon,
                  color: Colors.grey,
                ),
        ),
        readOnly: readOnly,
        validator: validatorLabel == null
            ? null
            : (value) {
                if (value == null || value.isEmpty) {
                  return validatorLabel;
                }
                return null;
              },
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );
  }

  Future<DateTime?> showPopupSelectDate(BuildContext context,
      {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
    DateTime now = DateTime.now();
    initialDate ??= now;
    firstDate ??= now;
    lastDate ??= now.add(const Duration(days: 366));
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    return picked;
  }

  Future<TimeOfDay?> showPopupSelectTime(
    BuildContext context,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return picked;
  }
}
