#!/usr/bin/env dart

import 'dart:io';

/*  
  SUPPORT: Windows, Linux, MacOS.
  
  This accesses your clipboard and does a wordcount operation on the text therein. It does so because some terminals --in my case ZSH-- interrupt I/O operations on running scripts if the user pastes in text containing newlines.  This is a conservative parser and reports any whitespace-delimited unit of text as a "word" (so "whitespace-delimited" is 1 word).
*/

Future<void> main(List<String> argumentVector) async {
  if (argumentVector.length != 0) {
    stdout.write('\nUSAGE:\t1. Copy text.\n\t2. Open Terminal.\n\t3. Run `howlong` with no command-line arguments.\n');
    exit(1);
  }

  final ProcessResult clipboardRead;

  if (Platform.isWindows) {
    clipboardRead = await Process.run('powershell', ['Get-Clipboard']);
  } else if (Platform.isMacOS) {
    clipboardRead = await Process.run('pbpaste', []);
  } else if (Platform.isLinux) {
    clipboardRead = await Process.run('xclip', ['-selection', 'clipboard', '-o']);
  } else {
    stdout.write('ERROR: Your OS is not supported by this script.');
    exit(2);
  }

  if (clipboardRead.exitCode == 0) {
    final byThese = RegExp(r'[\t\n\r\s]+');
    int wordCount = clipboardRead.stdout.toString().split(byThese).length;
    int characterCount = clipboardRead.stdout.toString().split('').length;
    print('${wordCount} / ${characterCount}');
  } else {
    stdout.write('ERROR: Your clipboard is empty, or contains unreadable data.\nExit code: ${clipboardRead.exitCode}\n');
    exit(3);
  }
}
