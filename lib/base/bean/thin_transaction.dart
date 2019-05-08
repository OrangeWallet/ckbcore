class ThinTransaction {
  String hash;
  int capacityIn;
  int capacityOut;

  ThinTransaction(this.hash, this.capacityIn, this.capacityOut);

  factory ThinTransaction.fromJson(Map<String, dynamic> json) => ThinTransaction(
        json['hash'] as String,
        json['capacityIn'] as int,
        json['capacityOut'] as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hash': hash,
        'capacityIn': capacityIn,
        'capacityOut': capacityOut,
      };
}
