import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/question/controller/question_controller.dart';
import 'package:solve_student/feature/question/models/question_search_model.dart';
import 'package:solve_student/feature/question/widgets/send_question_widget.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({required this.initQuestion, super.key});
  final List<QuestionSearchModel> initQuestion;
  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  QuestionController? controller;

  @override
  void initState() {
    controller = QuestionController(context, initQuestion: widget.initQuestion);
    controller!.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<QuestionController>(builder: (context, con, _) {
        return SafeArea(
          child: Align(
            alignment: const Alignment(0, 1),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Center(
                                    child: Text(
                                  "กรุณาตรวจสอบ ก่อนส่งคำถาม",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text("คำถามของคุณ : "),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: con.searchText,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "คำถามของคุณ",
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onFieldSubmitted: (value) {
                                con.setSearchText(value);
                              },
                              onChanged: (value) {
                                con.setSearchText(value);
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
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              print(con.questionSelected);
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // const SendQuestionWidget(),
                          Builder(builder: (context) {
                            // if (con.notFound) {
                            //   return notFoundWidget();
                            // }
                            return textListWidget(con, context);
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget textListWidget(QuestionController con, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "คำถามของคุณ เคยถูกถามมาแล้ว",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "3 คำถามด้านล่าง",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: ' ใกล้เคียง ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: "กับคำถามของคุณหรือไม่ ?",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount:
                con.questionList.length > 3 ? 3 : con.questionList.length,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              QuestionSearchModel only = con.questionList[index];
              return Builder(builder: (context) {
                Color textColor = Colors.black;
                BoxDecoration selectedStyle = BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                );
                if (con.questionSelected == only) {
                  textColor = primaryColor;
                  selectedStyle = BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: getMaterialColor(primaryColor).shade100,
                    border: Border.all(
                      color: primaryColor,
                      width: 2,
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    con.selectQuestion(only);
                  },
                  child: Container(
                    width: 150,
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    decoration: selectedStyle,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: Icon(
                            Icons.record_voice_over,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            only.questionText ?? "",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                              only,
                            );
                          },
                          child: Row(
                            children: [
                              const Text(
                                "ดูคำถาม",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_right_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () {
                if (con.questionSelected != null) {
                  Navigator.pop(
                    context,
                    con.questionSelected,
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "ดูคำตอบ",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column notFoundWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("ไม่พบคำถามของคุณ"),
        const Text(
          "ส่งคำถามใหม่ให้ติวเตอร์ \nระบบจะส่งแจ้งเตือนเมื่อติวเตอร์ตอบคำถามของคุณ",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          height: 45,
          width: 200,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              Text(
                "ส่งคำถามใหม่ให้ติวเตอร์",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
