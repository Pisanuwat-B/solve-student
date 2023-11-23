import 'package:flutter/material.dart';
import 'package:solve_student/feature/live_classroom/solvepad/solvepad_stroke_model.dart';

enum DrawingMode { drag, pen, eraser, laser, highlighter }

class SolvepadDrawer extends CustomPainter {
  SolvepadDrawer(
    this.penPoints,
    this.eraserPoint,
    this.laserPoints,
    this.highlighterPoints,
    this.hostPenPoints,
    this.hostLaserPoints,
    this.hostHighlighterPoints,
    this.hostEraserPoint, {
    this.questionHighlighterPoints = const [],
    this.answerHighlighterPoints = const [],
  });

  List<SolvepadStroke?> penPoints;
  List<SolvepadStroke?> laserPoints;
  List<SolvepadStroke?> highlighterPoints;
  Offset eraserPoint;
  List<SolvepadStroke?> hostPenPoints;
  List<SolvepadStroke?> hostLaserPoints;
  List<SolvepadStroke?> hostHighlighterPoints;
  Offset hostEraserPoint;
  List<SolvepadStroke?> questionHighlighterPoints;
  List<SolvepadStroke?> answerHighlighterPoints;

  Paint penPaint = Paint()..strokeCap = StrokeCap.round;
  Paint eraserPaint = Paint()
    ..color = Colors.green.withOpacity(0.1)
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;
  Paint borderPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  Paint laserPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  Paint highlightLayer = Paint()
    ..color = Colors.white.withOpacity(0.5)
    ..strokeWidth = 25
    ..strokeCap = StrokeCap.round;
  Paint highlightPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Paint hostPenPaint = Paint()..strokeCap = StrokeCap.round;
  Paint hostEraserPaint = Paint()
    ..color = Colors.green.withOpacity(0.1)
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;
  Paint hostBorderPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  Paint hostLaserPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  Paint hostHighlightLayer = Paint()
    ..color = Colors.white.withOpacity(0.5)
    ..strokeWidth = 25
    ..strokeCap = StrokeCap.round;
  Paint hostHighlightPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Paint questionHighlightPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  Paint answerHighlightPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < penPoints.length - 1; i++) {
      if (penPoints[i]?.offset != null && penPoints[i + 1]?.offset != null) {
        penPaint.color = penPoints[i]!.color;
        penPaint.strokeWidth = penPoints[i]!.width;
        canvas.drawLine(
            penPoints[i]!.offset, penPoints[i + 1]!.offset, penPaint);
      }
    }

    Path path = Path();
    bool newPath = true;
    int newStrokeIndex = 0;
    for (int i = 0; i < highlighterPoints.length - 1; i++) {
      if (highlighterPoints[i]?.offset == null) {
        canvas.drawPath(path, highlightPaint);
        path = Path();
        newPath = true;
        newStrokeIndex = i + 1;
        continue;
      }
      if (newPath) {
        path.moveTo(highlighterPoints[newStrokeIndex]!.offset.dx,
            highlighterPoints[newStrokeIndex]!.offset.dy);
        newPath = false;
      } else {
        path.lineTo(
            highlighterPoints[i]!.offset.dx, highlighterPoints[i]!.offset.dy);
      }
      highlightPaint.color =
          highlighterPoints[newStrokeIndex]!.color.withOpacity(0.4);
      highlightPaint.strokeWidth =
          (highlighterPoints[newStrokeIndex]!.width * 10) + 5;
    }
    canvas.drawPath(path, highlightPaint);

    for (int i = 0; i < laserPoints.length - 1; i++) {
      if (laserPoints[i] != null && laserPoints[i + 1] != null) {
        laserPaint.color = laserPoints[i]!.color.withOpacity(0.8);
        laserPaint.strokeWidth = laserPoints[i]!.width + 1;
        penPaint.strokeWidth = laserPoints[i]!.width;
        penPaint.color = laserPoints[i]!.color;
        canvas.drawLine(
            laserPoints[i]!.offset, laserPoints[i + 1]!.offset, laserPaint);
        canvas.drawLine(
            laserPoints[i]!.offset, laserPoints[i + 1]!.offset, penPaint);
      }
    }
    canvas.drawCircle(eraserPoint, 10, eraserPaint);
    canvas.drawCircle(eraserPoint, 10, borderPaint);

    for (int i = 0; i < hostPenPoints.length - 1; i++) {
      if (hostPenPoints[i]?.offset != null &&
          hostPenPoints[i + 1]?.offset != null) {
        hostPenPaint.color = hostPenPoints[i]!.color;
        hostPenPaint.strokeWidth = hostPenPoints[i]!.width;
        canvas.drawLine(hostPenPoints[i]!.offset, hostPenPoints[i + 1]!.offset,
            hostPenPaint);
      }
    }

    Path hostPath = Path();
    bool hostNewPath = true;
    int hostNewStrokeIndex = 0;
    for (int i = 0; i < hostHighlighterPoints.length - 1; i++) {
      if (hostHighlighterPoints[i]?.offset == null) {
        canvas.drawPath(hostPath, hostHighlightPaint);
        hostPath = Path();
        hostNewPath = true;
        hostNewStrokeIndex = i + 1;
        continue;
      }
      if (hostNewPath) {
        hostPath.moveTo(hostHighlighterPoints[hostNewStrokeIndex]!.offset.dx,
            hostHighlighterPoints[hostNewStrokeIndex]!.offset.dy);
        hostNewPath = false;
      } else {
        hostPath.lineTo(hostHighlighterPoints[i]!.offset.dx,
            hostHighlighterPoints[i]!.offset.dy);
      }
      hostHighlightPaint.color =
          hostHighlighterPoints[hostNewStrokeIndex]!.color.withOpacity(0.4);
      hostHighlightPaint.strokeWidth =
          (hostHighlighterPoints[hostNewStrokeIndex]!.width * 10) + 5;
    }
    canvas.drawPath(hostPath, hostHighlightPaint);

    for (int i = 0; i < hostLaserPoints.length - 1; i++) {
      if (hostLaserPoints[i] != null && hostLaserPoints[i + 1] != null) {
        hostLaserPaint.color = hostLaserPoints[i]!.color.withOpacity(0.8);
        hostLaserPaint.strokeWidth = hostLaserPoints[i]!.width + 1;
        hostPenPaint.strokeWidth = hostLaserPoints[i]!.width;
        hostPenPaint.color = hostLaserPoints[i]!.color;
        canvas.drawLine(hostLaserPoints[i]!.offset,
            hostLaserPoints[i + 1]!.offset, hostLaserPaint);
        canvas.drawLine(hostLaserPoints[i]!.offset,
            hostLaserPoints[i + 1]!.offset, hostPenPaint);
      }
    }
    canvas.drawCircle(hostEraserPoint, 10, hostEraserPaint);
    canvas.drawCircle(hostEraserPoint, 10, hostBorderPaint);

    Path questionPath = Path();
    bool questionNewPath = true;
    int questionNewStrokeIndex = 0;
    for (int i = 0; i < questionHighlighterPoints.length - 1; i++) {
      if (questionHighlighterPoints[i]?.offset == null) {
        canvas.drawPath(questionPath, questionHighlightPaint);
        questionPath = Path();
        questionNewPath = true;
        questionNewStrokeIndex = i + 1;
        continue;
      }
      if (questionNewPath) {
        questionPath.moveTo(
            questionHighlighterPoints[questionNewStrokeIndex]!.offset.dx,
            questionHighlighterPoints[questionNewStrokeIndex]!.offset.dy);
        questionNewPath = false;
      } else {
        questionPath.lineTo(questionHighlighterPoints[i]!.offset.dx,
            questionHighlighterPoints[i]!.offset.dy);
      }
      questionHighlightPaint.color =
          questionHighlighterPoints[questionNewStrokeIndex]!
              .color
              .withOpacity(0.4);
      questionHighlightPaint.strokeWidth =
          (questionHighlighterPoints[questionNewStrokeIndex]!.width * 10) + 5;
    }
    canvas.drawPath(questionPath, questionHighlightPaint);

    Path answerPath = Path();
    bool answerNewPath = true;
    int answerNewStrokeIndex = 0;
    for (int i = 0; i < questionHighlighterPoints.length - 1; i++) {
      if (questionHighlighterPoints[i]?.offset == null) {
        canvas.drawPath(answerPath, answerHighlightPaint);
        answerPath = Path();
        answerNewPath = true;
        answerNewStrokeIndex = i + 1;
        continue;
      }
      if (answerNewPath) {
        answerPath.moveTo(
            questionHighlighterPoints[answerNewStrokeIndex]!.offset.dx,
            questionHighlighterPoints[answerNewStrokeIndex]!.offset.dy);
        answerNewPath = false;
      } else {
        answerPath.lineTo(questionHighlighterPoints[i]!.offset.dx,
            questionHighlighterPoints[i]!.offset.dy);
      }
      answerHighlightPaint.color =
          questionHighlighterPoints[answerNewStrokeIndex]!
              .color
              .withOpacity(0.4);
      answerHighlightPaint.strokeWidth =
          (questionHighlighterPoints[answerNewStrokeIndex]!.width * 10) + 5;
    }
    canvas.drawPath(answerPath, answerHighlightPaint);
  }

  @override
  bool shouldRepaint(SolvepadDrawer oldDelegate) => true;
}

class SolvepadDrawerMarketplace extends CustomPainter {
  SolvepadDrawerMarketplace(
    this.penPoints,
    this.eraserPoint,
    this.laserPoints,
    this.highlighterPoints,
  );

  List<SolvepadStroke?> penPoints;
  List<SolvepadStroke?> laserPoints;
  List<SolvepadStroke?> highlighterPoints;
  Offset eraserPoint;

  Paint penPaint = Paint()..strokeCap = StrokeCap.round;
  Paint eraserPaint = Paint()
    ..color = Colors.green.withOpacity(0.1)
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;
  Paint borderPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  Paint laserPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  Paint highlightLayer = Paint()
    ..color = Colors.white.withOpacity(0.5)
    ..strokeWidth = 25
    ..strokeCap = StrokeCap.round;
  Paint highlightPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < penPoints.length - 1; i++) {
      if (penPoints[i]?.offset != null && penPoints[i + 1]?.offset != null) {
        penPaint.color = penPoints[i]!.color;
        penPaint.strokeWidth = penPoints[i]!.width;
        canvas.drawLine(
            penPoints[i]!.offset, penPoints[i + 1]!.offset, penPaint);
      }
    }

    Path path = Path();
    bool newPath = true;
    int newStrokeIndex = 0;
    for (int i = 0; i < highlighterPoints.length - 1; i++) {
      if (highlighterPoints[i]?.offset == null) {
        canvas.drawPath(path, highlightPaint);
        path = Path();
        newPath = true;
        newStrokeIndex = i + 1;
        continue;
      }
      if (newPath) {
        path.moveTo(highlighterPoints[newStrokeIndex]!.offset.dx,
            highlighterPoints[newStrokeIndex]!.offset.dy);
        newPath = false;
      } else {
        path.lineTo(
            highlighterPoints[i]!.offset.dx, highlighterPoints[i]!.offset.dy);
      }
      highlightPaint.color =
          highlighterPoints[newStrokeIndex]!.color.withOpacity(0.4);
      highlightPaint.strokeWidth =
          (highlighterPoints[newStrokeIndex]!.width * 10) + 5;
    }
    canvas.drawPath(path, highlightPaint);

    for (int i = 0; i < laserPoints.length - 1; i++) {
      if (laserPoints[i] != null && laserPoints[i + 1] != null) {
        laserPaint.color = laserPoints[i]!.color.withOpacity(0.8);
        laserPaint.strokeWidth = laserPoints[i]!.width + 1;
        penPaint.strokeWidth = laserPoints[i]!.width;
        penPaint.color = laserPoints[i]!.color;
        canvas.drawLine(
            laserPoints[i]!.offset, laserPoints[i + 1]!.offset, laserPaint);
        canvas.drawLine(
            laserPoints[i]!.offset, laserPoints[i + 1]!.offset, penPaint);
      }
    }
    canvas.drawCircle(eraserPoint, 10, eraserPaint);
    canvas.drawCircle(eraserPoint, 10, borderPaint);
  }

  @override
  bool shouldRepaint(SolvepadDrawerMarketplace oldDelegate) => true;
}
