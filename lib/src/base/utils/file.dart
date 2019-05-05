import 'dart:io';

Future<String> readFromFile(File file) async {
  List<String> verifyScript_lines = await file.readAsLines();
  String verifyScript = "";
  verifyScript_lines.forEach((line) {
    verifyScript += line;
  });
  return verifyScript;
}

Future writeToFile(String contents, File file) async {
  await file.writeAsString(contents);
  return;
}

Future delete(File file) async {
  await file.deleteSync();
}
