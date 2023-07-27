class Days {
  int id;
  String day;
  bool selected;
  int sum;
  Days({
    required this.id,
    required this.day,
    this.selected = false,
    this.sum = 0,
  });
}
