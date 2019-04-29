import 'dart:io';

Future<String> readFromFile(String path) async {
  File file = File(path);
  List<String> verifyScript_lines = await file.readAsLines();
  String verifyScript = "";
  verifyScript_lines.forEach((line) {
    verifyScript += line;
  });
  return verifyScript;
}

Future writeToFile(String contents, String path) async {
  File file = File(path);
  await file.writeAsString(contents);
  return;
}
