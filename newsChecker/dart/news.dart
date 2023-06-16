// Core libs
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

// External libs
import 'package:news_api_flutter_package/news_api_flutter_package.dart'; // https://pub.dev/packages/news_api_flutter_package
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/error.dart';
import 'package:hackernews_api/hackernews_api.dart'; // https://pub.dev/packages/hackernews_api
import 'package:hackernews_api/helper/exception.dart';
// import 'package:ipapi/ipapi.dart'; // https://pub.dev/packages/ipapi
import 'package:colorize/colorize.dart';

// Files
import 'keys.dart';

/// This is essentially my attempt at making my own ultra-minimal old RSS-style terminal news program.

/// TODO: integrate webpage scraper: https://pub.dev/packages/web_scraper
/// TODO: add submenus to 中国語と日本語なの

void main() async {
  // stdin.echoMode = false; /// For debug
  // stdin.lineMode = false; /// For debug

  clearTerminal();

  /// See `ipapi` package above.
  // final GeoData? currentLocation = await IpApi.getData();
  // if (currentLocation?.countryCode == 'CN') {
  //   validSites(mainlandSources);
  //   exit(0);
  // }

  /// Present options menu
  stdout.write('1. Hacker News\n2. Generic News\n3. 日本ニュース\n4. 中国新闻\n\n');

  int? userChoice = null;
  while (userChoice == null || (userChoice > 4 || userChoice < 1)) {
    printMagenta('Choice: ');
    userChoice = int.tryParse(stdin.readLineSync()!); // tryparse returns null if err
  }

  if (userChoice == 1) {
    /// Hacker News sources
    clearTerminal();

    stdout.write('1. Top Stories\n2. New Stories\n3. Ask Stories\n4. Job Stories\n\n');

    int? storyType = null;
    while (storyType == null || (storyType > 4 || storyType < 1)) {
      printMagenta('Choice: ');
      storyType = int.tryParse(stdin.readLineSync()!);
    }

    final int result = await getHackerNews(storyType);
    exit(result);
  } else if (userChoice == 2) {
    /// Generic Western news sources
    final int result = await newsAPI(engSources, 60);
    exit(result);
  } else if (userChoice == 3) {
    /// 日本語、朝日新聞などなど
    final int result = await newsAPI(jpSources, 40);
    exit(result);
  } else if (userChoice == 4) {
    /// 中文報紙等等
    final int result = await newsAPI(zhSources, 40);
    exit(result);
  } else {
    /// it will never get here
    stdout.write('ERROR: failed to handle user input variable `userChoice`.\n');
    exit(2);
  }
}

Future<int> getHackerNews(int choice) async {
  HackerNews news = HackerNews(
    newsType: (() {
      switch (choice) {
        case 1:
          return NewsType.topStories;
        case 2:
          return NewsType.newStories;
        case 3:
          return NewsType.askStories;
        case 4:
          return NewsType.jobStories;
        default:
          throw Exception(
              'ERROR: Invalid parameter "choice" erroneously passed to HackerNews constructor.');
      }
    })(),
  );

  final Duration timeoutDuration = Duration(seconds: 10);
  bool hasTimedOut = false;

  List<Story>? stories;
  final Future<List<Story>> storiesFuture = news.getStories();

  await Future.any([
    storiesFuture.then((List<Story> value) => stories = value) /* success */,
    Future.delayed(timeoutDuration).then((_) => hasTimedOut = true) /* timeout */,
  ]).catchError((error) {
    if (error is NewsException) {
      stdout.write('API ERROR: NewsException: ${error.message}');
    } else {
      stdout.write('ERROR: unable to retrieve data due to exception: $error');
    }
  });

  if (hasTimedOut) {
    stdout.writeln('ERROR: Timeout occurred while fetching news article data.');
    return 1;
  }
  if (stories == null || stories!.isEmpty) {
    stdout.writeln(
        'ERROR: Failed to fetch news article data. This may be due to connectivity problems or API gateway issues.');
    return 1;
  }

  clearTerminal();
  stdout.write('\n');

  stories!.sort((a, b) => a.score.compareTo(b.score));
  // List<Story> reversedSublist = stories!.reversed.toList().sublist(0, 20);

  for (Story story in stories!.reversed) {
    if (story.dead == true || story.url == 'null' || story.deleted == true) {
      continue;
    }
    if (techBlacklist.any((e) => story.title.toLowerCase().contains(e.toLowerCase()))) {
      continue;
    }

    final int daysCounter =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(story.time * 1000)).inDays;

    final String when = daysCounter == 0
        ? "today"
        : daysCounter == 1
            ? "yesterday"
            : "more than a day ago";

    final String title = trim(story.title);

    stdout.write('#${stories!.indexOf(story) + 1} － ');

    if (techPromoteList
        .any((String element) => story.title.toLowerCase().contains(element.toLowerCase()))) {
      printMagenta('$title ');
    } else {
      printCyan('$title ');
    }

    printLightGrey(
        '\nby ${story.by} $when with ${story.score} point${story.score == 1 ? "" : "s"}\n');
    // stdout.write(story.url);

    printClickableLink('READ', story.url);
    stdout.write('\n\n');
  }
  return 0;
}

Future<int> newsAPI(List<Map<String, dynamic>> sources, int maxLength) async {
  final NewsAPI _newsAPI = NewsAPI(newsAPIkey);
  final DateTime now = DateTime.now();
  final Duration oneWeek = Duration(days: 5);
  final DateTime oneWeekAgo = now.subtract(oneWeek);

  /// For debug & updating
  // List<Source> gotSources = await _newsAPI.getSources();
  // for (Source src in gotSources) {
  //   print(src);
  // }

  List<Article>? articleList;

  try {
    /// get general news headlines from prespecified sources
    articleList = await _newsAPI.getTopHeadlines(
      sources: sources[0]['source'] /* Can't mix `sources:` with `category:` in same request */,
      pageSize: sources[0]['number'],
      country: sources[0]['country'],
      category: sources[0]['category'],
    );
  } on ApiError catch (e) {
    stdout.write('API error: ${e.message}');
  } catch (e) {
    stdout.write('Unexpected error: $e');
  }

  /// Get from a specific DOMAIN
  if (articleList != null) {
    try {
      articleList += await _newsAPI.getEverything(
        domains: sources[1]['source'] as String,
        pageSize: sources[1]['number'] as int,
        from: oneWeekAgo,
        to: now,
      );
    } on ApiError catch (e) {
      stdout.write('API error: ${e.message}');
    } catch (e) {
      stdout.write('Unexpected error: $e');
    }
  }

  /// After here NewsAPI won't return null; it'll just return an empty List
  if (articleList!.isEmpty) {
    print(
        'ERROR: The data request was made successfully, but the source did not return article data. This may be due to connectivity problems or API gateway issues.');
    return 1;
  }

  stdout.write('\n');
  articleList.shuffle();

  for (Article art in articleList) {
    if (newsBlacklist.any((e) => art.title!.toLowerCase().contains(e.toLowerCase()))) {
      continue;
    }

    final String title = trim(art.title!);

    stdout.write('#${articleList.indexOf(art) + 1} － ');

    if (newsPromoteList.any((e) => art.title!.toLowerCase().contains(e.toLowerCase()))) {
      printMagenta('${title} \n');
    } else {
      printCyan('${title} \n');
    }

    if (art.description != null) {
      printLightGrey('${art.description}\n');
    }

    final String timestamp = DateFormat('yyyy-MM-dd').format(DateTime.parse(art.publishedAt!));

    if (art.author != null) {
      printLightGrey('Published by ${art.author} on $timestamp\n');
    } else {
      printLightGrey('Published on $timestamp\n');
    }

    printDarkGrey('${art.url}\n\n');
  }

  return 0;
}

void printClickableLink(String text, String url) {
  if (Platform.isWindows) {
    printDarkGrey('$text ($url)');
  } else if (Platform.isMacOS) {
    if (Platform.environment['TERM_PROGRAM'] == 'Apple_Terminal') {
      /// Terminal.app with ZSH doesn't support hyperlinks, so just print the URL
      printDarkGrey(url);
    } else {
      /// Visual Studio Code terminal DOES so if I call from here I can have nice clean hyperlinks
      printDarkGrey('\u001B]8;;$url\u001B\\$text\u001B]8;;\u001B\\');
    }
  } else if (Platform.isLinux) {
    printDarkGrey(url);
  } else {
    printDarkGrey(url);
  }
}

void autoScrollUpwards() {
  /// >2023
  /// >still having ANSI escape sequences
  stdout.write('\x1B[1;1H');
  return;
}

void clearTerminal() {
  /// If using Terminal.app, running a 'clear' command just adds empty space equivalent to the
  /// number of \n that fit in the terminal. Scrolling up through the links into this empty space
  /// is irratating, so it will only perform a clear if I call this script from the VSc terminal.
  ///
  if (Platform.environment['TERM_PROGRAM'] != 'Apple_Terminal') {
    stdout.write(Process.runSync('clear', [], runInShell: true).stdout);
  }
}

String trim(String title) {
  int maxLen;
  if (stdout.hasTerminal) {
    maxLen = stdout.terminalColumns - 7;
  } else {
    maxLen = 60;
  }

  final String edit = title.length > maxLen ? title.substring(0, (maxLen - 7)) + "..." : title;
  return edit;
}

void validSites(Map<String, String> sources) {
  print('Sites you can visit: \n');
  sources.forEach((name, link) {
    stdout.write('$name: $link\n');
  });
}

void briefPause(String url) async {
  await Future.delayed(Duration(milliseconds: 475));
}

void moveToPosition(int row, int column) {
  /// Unless a workaround is found this won't be used; it just pushes the cursor up to the
  /// 1st position in the terminal, but is buggy due to how a CLRSCRN command adds blank lines
  final String positionCode = '\x1B[${row};${column}H';
  stdout.write(positionCode);
}

void printCyan(String text) => stdout.write(Colorize(text).cyan());
void printYellow(String text) => stdout.write(Colorize(text).yellow());
void printMagenta(String text) => stdout.write(Colorize(text).lightMagenta());
void printRed(String text) => stdout.write(Colorize(text).red());
void printDarkGrey(String text) => stdout.write(Colorize(text).darkGray());
void printLightGrey(String text) => stdout.write(Colorize(text).lightGray());
