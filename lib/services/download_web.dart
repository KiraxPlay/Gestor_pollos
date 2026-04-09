// Implementación web — solo se compila cuando el target es web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadFileWeb(List<int> bytes, String fileName) async {
  final blob = html.Blob([bytes], 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final link = html.AnchorElement(href: url)
    ..target = '_blank'
    ..download = fileName;
  html.document.body!.append(link);
  link.click();
  html.document.body!.children.remove(link);
  await Future.delayed(const Duration(milliseconds: 100));
  html.Url.revokeObjectUrl(url);
}
