class BalanceBean {
  int totalCapacity;
  int availableCapacity;

  BalanceBean(this.totalCapacity, this.availableCapacity);

  factory BalanceBean.fromJson(Map<String, dynamic> json) => BalanceBean(
        json['totalCapacity'] as int,
        json['availableCapacity'] as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalCapacity': totalCapacity,
        'availableCapacity': availableCapacity,
      };
}
