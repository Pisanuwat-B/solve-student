import 'package:flutter/material.dart';
import 'package:slove_student/constants/school_subject_constants.dart';
import 'package:slove_student/feature/class/models/filter_class_model.dart';
import 'package:slove_student/widgets/date_time_format_util.dart';

enum DateTimeEnum { date, time }

class FilterClassWidget extends StatefulWidget {
  FilterClassWidget({super.key, required this.data});
  final FilterClassModel data;
  @override
  State<FilterClassWidget> createState() => _FilterClassWidgetState();
}

class _FilterClassWidgetState extends State<FilterClassWidget> {
  FilterClassModel? data;
  String selectClass = SchoolSubJectConstants.schoolSubJectFilterList.first;
  String selectClassLevel = SchoolSubJectConstants.schoolFilterClassLevel.first;
  DateTimeEnum? isDateTimeEnum;
  final txtStartDate = TextEditingController();
  final txtStartTime = TextEditingController();
  // String? startDate;
  // String? startTime;

  init() {
    data = widget.data;
    selectClass = data!.schoolSubject;
    selectClassLevel = data!.classLevel;
    if (data!.startDate != "") {
      isDateTimeEnum = DateTimeEnum.date;
      txtStartDate.text = data!.startDate;
    }
    if (data!.startTime != "") {
      isDateTimeEnum = DateTimeEnum.time;
      txtStartTime.text = data!.startTime;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 110,
                    child: IconButton(
                        onPressed: () {
                          isDateTimeEnum = null;
                          setState(() {});
                        },
                        icon: Row(
                          children: [
                            const Icon(Icons.clear),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text('ล้างข้อมูล'),
                          ],
                        )),
                  ),
                ],
              ),
              schoolSubjectAndLevelClass(),
              const SizedBox(
                height: 30,
              ),
              buildStartDateTimeBody(),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String sDate = "";
                    if ((isDateTimeEnum == DateTimeEnum.date &&
                        txtStartDate.text != "")) {
                      sDate = txtStartDate.text;
                    }

                    String sTime = "";
                    if ((isDateTimeEnum == DateTimeEnum.time &&
                        txtStartTime.text != "")) {
                      sTime = txtStartTime.text;
                    }
                    FilterClassModel result = FilterClassModel(
                        schoolSubject: selectClass,
                        classLevel: selectClassLevel,
                        startDate: sDate,
                        startTime: sTime);
                    Navigator.of(context).pop(result);
                  },
                  child: const Text('ค้นหา'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget schoolSubjectAndLevelClass() {
    return Row(
      children: [
        Expanded(child: buildSchoolSubject()),
        const SizedBox(width: 20),
        Expanded(child: buildClassLevel()),
      ],
    );
  }

  Widget buildSchoolSubject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'วิชาเรียน',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 50,
          child: DropdownButtonFormField(
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
            items: SchoolSubJectConstants.schoolSubJectFilterList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildClassLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ระดับชั้น',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 50,
          child: DropdownButtonFormField(
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
            items: SchoolSubJectConstants.schoolFilterClassLevel
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildStartDateTimeBody() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('ระยะเวลาเริ่มเรียน'),
                leading: Radio<DateTimeEnum>(
                  value: DateTimeEnum.date,
                  groupValue: isDateTimeEnum,
                  onChanged: (DateTimeEnum? value) {
                    setState(() {
                      isDateTimeEnum = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('เวลาเรียน'),
                leading: Radio<DateTimeEnum>(
                  value: DateTimeEnum.time,
                  groupValue: isDateTimeEnum,
                  onChanged: (DateTimeEnum? value) {
                    setState(() {
                      isDateTimeEnum = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Visibility(
          visible: isDateTimeEnum == DateTimeEnum.date,
          child: txtFieldBody(
              txtCtrl: txtStartDate,
              hint: "เลือกวันที่",
              validatorLabel: 'กรุณาเลือกวันที่',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () async {
                DateTime? getDate = await showPopupSelectDate(context);
                if (getDate != null) {
                  txtStartDate.text = getDate.date();
                  // selectStartDate = getDate;
                  setState(() {});
                }
              }),
        ),
        Visibility(
          visible: isDateTimeEnum == DateTimeEnum.time,
          child: txtFieldBody(
            txtCtrl: txtStartTime,
            hint: "เลือกเวลา",
            validatorLabel: 'กรุณาเลือกเวลา',
            icon: Icons.timer_outlined,
            readOnly: true,
            onTap: () async {
              TimeOfDay? getTime = await showPopupSelectTime(context);
              if (getTime != null) {
                // print('object: ${getTime}');
                txtStartTime.text =
                    "${getTime.hour.toString().padLeft(2, '0')}:${getTime.minute.toString().padLeft(2, '0')}";
                // selectEndTime = DateTime(
                //   selectEndDate.year,
                //   selectEndDate.month,
                //   selectEndDate.day,
                //   getTime.hour,
                //   getTime.minute,
                // );
                setState(() {});
              }
            },
          ),
        ),
      ],
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
