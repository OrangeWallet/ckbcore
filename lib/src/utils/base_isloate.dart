import 'dart:isolate';

Isolate isolate;

destroy() {
  if (isolate != null) {
    isolate.kill(priority: Isolate.immediate);
    isolate = null;
  }
}
