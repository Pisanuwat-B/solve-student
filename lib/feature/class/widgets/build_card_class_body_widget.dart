import 'package:flutter/material.dart';
import 'package:slove_student/feature/class/models/class_model.dart';
import 'package:slove_student/widgets/date_time_format_util.dart';

class BuildCardClassBodyWidget extends StatelessWidget {
  BuildCardClassBodyWidget(this.item, this.onTap, {super.key});
  ClassModel item;
  Function(ClassModel item) onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          onTap(item);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        // image: DecorationImage(
                        //   image: item.image == null
                        //       ? AssetImage(
                        //           'assets/images/img_not_available.jpeg',
                        //         )
                        //       : NetworkImage(
                        //           item.image!,
                        //         ),
                        //   fit: BoxFit.fitWidth,
                        // ),
                        ),
                    child: item.image == null
                        ? Image.asset(
                            'assets/images/img_not_available.jpeg',
                            fit: BoxFit.fitWidth,
                          )
                        : Image.network(
                            item.image!,
                            fit: BoxFit.fitWidth,
                          ),
                  ),
                ),
                Container(
                  // color: Colors.green,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: ShapeDecoration(
                              color: Colors.grey.shade300,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              '${item.count == null || item.count == "" ? "-" : item.count} ครั้ง',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: ShapeDecoration(
                              color: Colors.grey.shade300,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              '${item.schoolSubject}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: ShapeDecoration(
                              color: Colors.grey.shade300,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              '${item.classLevel}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${item.name}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${item.detail}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'วันที่ : ${item.startDate?.date() ?? ""}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Text(
                          //   'เวลา : ${item.startTime?.time() ?? ""}',
                          //   style: const TextStyle(
                          //       fontSize: 14, color: Colors.grey),
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              item.creatorName == null || item.creatorName == ""
                                  ? "-"
                                  : item.creatorName!,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // const Text('data'),
                          Icon(
                            Icons.money,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            item.price == null || item.price == ""
                                ? "-"
                                : item.price!,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
