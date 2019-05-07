class HDCoreConfig {
  final String mnemonic;
  final String seed;
  final int receiveIndex;
  final int changeIndex;

  HDCoreConfig(this.mnemonic, this.seed, this.receiveIndex, this.changeIndex);

  factory HDCoreConfig.fromJson(Map<String, dynamic> json) => HDCoreConfig(
        json['mnemonic'] as String,
        json['seed'] as String,
        json['receiveIndex'] as int,
        json['changeIndex'] as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mnemonic': mnemonic,
        'seed': seed,
        'receiveIndex': receiveIndex,
        'changeIndex': changeIndex,
      };
}
