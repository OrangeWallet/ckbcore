class KeystoreConfig {
  final String mnemonic;
  //myWallet privateKey seed nor mnemonic seed
  final String seed;

  KeystoreConfig(this.mnemonic, this.seed);

  factory KeystoreConfig.fromJson(Map<String, dynamic> json) => KeystoreConfig(
        json['mnemonic'] as String,
        json['seed'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mnemonic': mnemonic,
        'seed': seed,
      };
}
