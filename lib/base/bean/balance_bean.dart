class BalanceBean {
  String totalCapacity;
  String availableCapacity;

  BalanceBean(this.totalCapacity, this.availableCapacity);

  factory BalanceBean.fromJson(Map<String, dynamic> json) => BalanceBean(
        json['totalCapacity'] as String,
        json['availableCapacity'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalCapacity': totalCapacity,
        'availableCapacity': availableCapacity,
      };
}
