import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/class/models/class_model.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:solve_student/feature/order/service/order_mock_provider.dart';
import 'package:solve_student/widgets/sizer.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({
    super.key,
    required this.orderDetailId,
  });
  String orderDetailId;
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  _PaymentPageState();
  OrderClassModel? orderDetail;
  List<Bank> bankImageList = [
    Bank("เงินสด", 'assets/images/add-income.png'),
    // Bank("บัตรเครดิต", 'assets/images/visa1.png'),
    // Bank("โอนผ่านธนาคาร", 'assets/images/scb_easy.png'),
    // Bank("พร้อมเพย์", 'assets/images/promptpay.png'),
    // Bank("TrueMoney Wallet", 'assets/images/truemoney.png'),
  ];
  Bank? paymentSelected;
  ClassModel? classInOrder;
  getClass() async {
    try {
      classInOrder = await OrderMockProvider()
          .getClassTutorInfo(orderDetail?.classId ?? "");
      setState(() {});
    } catch (e) {
      log("error : $e");
    }
  }

  getOrderDetail() async {
    try {
      orderDetail =
          await OrderMockProvider().getOrderDetail(widget.orderDetailId);
      log("orderDetail ${orderDetail?.toJson()}");
      setState(() {});
    } catch (e) {
      log("error : $e");
    }
  }

  init() async {
    await getOrderDetail();
    await getClass();
  }

  late AuthProvider auth;
  late OrderMockProvider order;
  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    order = Provider.of<OrderMockProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      order.init(auth: auth);
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "ชำระเงิน",
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
      body: Container(
        width: Sizer(context).w,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "กรุณาตรวจสอบคำสั่งซื้อ",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "คำสั่งซื้อ : ${orderDetail?.refId ?? ""} ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Builder(builder: (context) {
                    String text = "รอชำระค่าบริการ";
                    Color color = Colors.orange;
                    switch (orderDetail?.paymentStatus) {
                      case "paid":
                        text = "ชำระค่าบริการเรียบร้อย";
                        color = Colors.green;
                        break;
                      default:
                    }
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: color),
                        color: color.withOpacity(0.2),
                      ),
                      child: Text(
                        "$text ",
                        style: TextStyle(
                          fontSize: 15,
                          color: color,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderDetail?.title ?? "",
                      style: const TextStyle(
                        color: appTextPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "ระยะเวลาเรียน : ",
                      style: TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      orderDetail?.content ?? "",
                      style: TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "ดูรายละเอียดแนบปฏิทิน",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Image.network(
                            "",
                            errorBuilder: (context, error, stackTrace) {
                              return FittedBox(
                                child: Image.asset(
                                  "assets/images/image35.png",
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classInOrder?.creatorName ?? "",
                                style: const TextStyle(
                                  color: appTextPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "ข้อมูลเบื้องต้น",
                                style: const TextStyle(
                                  color: greyColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/point1.png",
                                    width: 30,
                                    height: 30,
                                  ),
                                  Text(
                                    "500 คะแนน",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Expanded(
                    //       child: Wrap(
                    //         runSpacing: 5.0,
                    //         spacing: 5.0,
                    //         alignment: WrapAlignment.start,
                    //         crossAxisAlignment: WrapCrossAlignment.center,
                    //         children: [
                    //           Container(
                    //             decoration: BoxDecoration(
                    //               color: Colors.grey.shade300,
                    //               borderRadius: BorderRadius.circular(10),
                    //             ),
                    //             margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    //             padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    //             child: Text(
                    //               "จำนวน 10 ครั้ง",
                    //               style: const TextStyle(
                    //                 fontSize: 15,
                    //               ),
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Wrap(
                    //         runSpacing: 5.0,
                    //         spacing: 5.0,
                    //         alignment: WrapAlignment.end,
                    //         crossAxisAlignment: WrapCrossAlignment.center,
                    //         children: [
                    //           Container(
                    //             decoration: BoxDecoration(
                    //               color: Colors.grey.shade300,
                    //               borderRadius: BorderRadius.circular(10),
                    //             ),
                    //             margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    //             padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    //             child: Text(
                    //               "ภาษาไทย",
                    //               style: const TextStyle(
                    //                 fontSize: 15,
                    //               ),
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //             ),
                    //           ),
                    //           Container(
                    //             decoration: BoxDecoration(
                    //               color: Colors.grey.shade300,
                    //               borderRadius: BorderRadius.circular(10),
                    //             ),
                    //             margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    //             padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    //             child: Text(
                    //               "ประถม 1",
                    //               style: const TextStyle(
                    //                 fontSize: 15,
                    //               ),
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "รายละเอียดการชำระเงิน",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "ยอดรวมชำระทั้งหมด",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${classInOrder?.price ?? 0}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("รหัสสินค้า : ${orderDetail?.refId}"),
                    Row(
                      children: [
                        Expanded(
                          child: Text("ราคาคอร์ส"),
                        ),
                        Expanded(
                          child: Text(
                            "${classInOrder?.price ?? 0}",
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text("ยอดรวม"),
                        ),
                        Expanded(
                          child: Text(
                            "${classInOrder?.price ?? 0}",
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text("ส่วนลด"),
                        ),
                        Expanded(
                          child: Text(
                            "0",
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text("ยอดรวมชำระทั้งหมด"),
                        ),
                        Expanded(
                          child: Text(
                            "${classInOrder?.price ?? 0}",
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "เลือกช่องทางชำระเงิน",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                height: 180,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: bankImageList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        paymentSelected = bankImageList[index];
                        setState(() {});
                      },
                      child: Container(
                        height: 200,
                        width: 200,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: paymentSelected == bankImageList[index]
                              ? primaryColor.withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                            color: paymentSelected == bankImageList[index]
                                ? primaryColor
                                : Colors.grey,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              bankImageList[index].image ?? "",
                              width: 100,
                              height: 100,
                            ),
                            Text("${bankImageList[index].name}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (paymentSelected != null) {
            orderDetail = await order.updateOrderStatus(
              orderDetail?.id ?? "",
              "paid",
              paymentSelected?.name ?? "",
            );
            setState(() {});
            Navigator.pop(context);
          }
        },
        child: Container(
          width: Sizer(context).w,
          height: 50,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            "ชำระค่าบริการ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class Bank {
  Bank(this.name, this.image);
  String? name;
  String? image;
}
