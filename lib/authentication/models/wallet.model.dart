class WalletModel {
  WalletModel({this.uid, this.balance, this.liveDuration, this.transaction});
  String? uid;
  int? balance;
  int? liveDuration;
  List<dynamic>? transaction;

  WalletModel.fromJson(Map<String, dynamic> json) {
    uid = json['user_id'] ?? '';
    balance = json['balance'] ?? 0;
    liveDuration = json['live_duration'] ?? 0;
    transaction = json['transaction'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user_id'] = uid;
    data['balance'] = balance;
    data['live_duration'] = liveDuration;
    data['transaction'] = transaction;
    return data;
  }
}
