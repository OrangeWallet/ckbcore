class IsolateResultBase<T> {
  final bool status;
  final Exception errorMessage;
  final T result;

  IsolateResultBase(this.status, this.errorMessage, this.result);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        'errorMessage': errorMessage,
        'result': result,
      };
}
