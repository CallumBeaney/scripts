import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/error.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:hackernews_api/hackernews_api.dart';
import 'package:colorize/colorize.dart';

/// This is essentially my attempt at making my own ultra-minimal old RSS-style terminal news program.

// Future<List<Source>> _sources = _newsAPI.getSources();
// https://newsapi.org/v2/sources?x=y&apiKey=34984eeaaece433c812780af807e3dda

List<String> _techBlacklist = [
  'ChatGPT',
  'GPT',
  'AI',
  'Apple',
  'Amazon',
  'openAI',
  'Twitter',
  'Musk',
  'iOS',
];
List<String> _newsBlacklist = [
  'shooting',
  'trump',
  'prince harry',
  'markle',
  'king charles',
  'piers morgan',
  'boris johnson',
  'football',
  'sports',
  'mogg',
  'primaries',
  'royal family',
  'musk',
  'twitter',
  '<a',
  'Kardashian',
  'kanye',
];
List<String> _techPromoteList = [
  'tool',
  'Dart',
  'Flutter',
  'ASM',
  'ANSI',
  'ISO',
  " C ",
  'Cambridge',
  'Raspberry Pi',
  'China',
  'Japan',
  'UK',
  'France',
];
List<String> _newsPromoteList = [
  'Cambridge',
  'inflation',
  'China',
  'Japan',
  'UK',
  'France',
  'Colonies',
];

void main() async {
  clearTerminal();
  stdout.write('1. Hacker News\n2. Generic News\n3. 日本ニュース\n4. 中国新闻\n');

  int? userChoice = null;
  while (userChoice == null || (userChoice > 4 || userChoice < 1)) {
    stdout.write('\nChoice: ');
    userChoice = int.parse(stdin.readLineSync()!);
  }

  if (userChoice == 1) {
    clearTerminal();
    int? storyType = null;
    stdout.write('1. Top Stories\n2. New Stories\n3. Ask Stories\n4. Job Stories\n');
    while (storyType == null || (storyType > 4 || storyType < 1)) {
      stdout.write('\nChoice: ');
      storyType = int.parse(stdin.readLineSync()!);
    }
    getHackerNews(storyType);
  } else if (userChoice == 2) {
    newsAPI();
  } else if (userChoice == 3) {
  } else if (userChoice == 4) {
  } else {}
}

void getHackerNews(int choice) async {
  // // Disable standard input echoing
  // stdin.echoMode = false;

  // // Disable standard input line mode
  // stdin.lineMode = false;

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

  // List<Story> stories = await news.getStories();

  Duration timeoutDuration = Duration(seconds: 10);
  Future<List<Story>> storiesFuture = news.getStories();

  List<Story>? stories;
  bool hasTimedOut = false;

  await Future.any([
    storiesFuture.then((value) => stories = value),
    Future.delayed(timeoutDuration).then((_) => hasTimedOut = true),
  ]);

  if (hasTimedOut) {
    stdout.writeln('ERROR: Timeout occurred while fetching news article data.');
    exit(1);
  }
  if (stories == null || stories!.isEmpty) {
    stdout.writeln(
        'ERROR: Failed to fetch news article data. This may be due to connectivity problems or API gateway issues.');
    return;
  }

  clearTerminal();

  stories!.sort((a, b) => a.score.compareTo(b.score));
  // List<Story> reversedSublist = stories!.reversed.toList().sublist(0, 20);

  for (Story story in stories!.reversed) {
    if (story.dead == true || story.url == 'null' || story.deleted == true) {
      continue;
    }
    if (_techBlacklist.any((e) => story.title.toLowerCase().contains(e.toLowerCase()))) {
      continue;
    }

    // String timestamp = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(story.time * 1000));
    int daysCounter =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(story.time * 1000)).inDays;

    String when = daysCounter == 0
        ? "today"
        : daysCounter == 1
            ? "yesterday"
            : "more than a day ago";

    if (_techPromoteList.any((e) => story.title.toLowerCase().contains(e.toLowerCase()))) {
      printYellow('－');
      stdout.write(' ${story.title} ');
    } else {
      stdout.write('－ ${story.title} ');
    }

    stdout.write('\nby ${story.by} $when with ${story.score} points\n');
    stdout.write(story.url);

    // printClickableLink('READ', story.url);
    stdout.write('\n\n');
  }

  // autoScrollUpwards();
}

void newsAPI() async {
  NewsAPI _newsAPI = NewsAPI('34984eeaaece433c812780af807e3dda');
  DateTime now = DateTime.now();
  Duration oneWeek = Duration(days: 5);
  DateTime oneWeekAgo = now.subtract(oneWeek);

  // Future<List<Source>> _sources = _newsAPI.getSources();
  // stdout.write(_sources);

  List<Article>? articleList;

  try {
    articleList = await _newsAPI.getTopHeadlines(
      sources: 'reuters,bbc-news' /* Can't mix with category */,
      pageSize: 11,
    );

    articleList += await _newsAPI.getEverything(
      domains: 'apnews.com',
      from: oneWeekAgo,
      to: now,
      pageSize: 11,
    );
    clearTerminal();
  } catch (e) {
    if (e is ApiError) {
      stdout.write('ERROR: $e.message');
    } else {
      stdout.write('Unexpected error: $e');
    }
  }

  /// After here NewsAPI won't return null; it'll just return an empty List
  if (articleList!.isEmpty) {
    print(
        'ERROR: Failed to fetch news article data. This may be due to connectivity problems or API gateway issues.');
    exit(1);
  }

  articleList.shuffle();

  for (Article a in articleList) {
    // printClickableLink('READ\n', a.url!);
    // if (_newsBlacklist.any((e) => a.title!.toLowerCase().contains(e.toLowerCase()))) {
    //   continue;
    // }

    if (_newsPromoteList.any((e) => a.title!.toLowerCase().contains(e.toLowerCase()))) {
      printCyan('－');
      stdout.write(' ${a.title}\n');
    } else {
      stdout.write('－ ${a.title}\n');
    }

    String timestamp = DateFormat('yyyy-MM-dd').format(DateTime.parse(a.publishedAt!));

    if (a.description != null) {
      stdout.write('${a.description}\n');
    }

    if (a.author != null) {
      stdout.write('Published by ${a.author} on $timestamp\n');
    } else {
      stdout.write('Published on $timestamp\n');
    }

    stdout.write('${a.url}\n\n');

    // stdout.write(a.content);

    // https://newsapi.org/v2/sources?x=y&apiKey=34984eeaaece433c812780af807e3dda
  }
}

void printClickableLink(String text, String url) {
  if (Platform.isWindows) {
    stdout.write('$text ($url)');
  } else {
    stdout.write('\u001B]8;;$url\u001B\\$text\u001B]8;;\u001B\\');
  }
}

void autoScrollUpwards() {
  /// >2023
  /// >still having ANSI escape sequences
  stdout.write('\x1B[1;1H');
  return;
}

void clearTerminal() {
  stdout.write(Process.runSync('clear', [], runInShell: true).stdout);
}

void briefPause() async {
  await Future.delayed(Duration(milliseconds: 475));
}

void moveToPosition(int row, int column) {
  final positionCode = '\x1B[${row};${column}H';
  stdout.write(positionCode);
}

void printCyan(String text) => stdout.write(Colorize(text).cyan());
void printYellow(String text) => stdout.write(Colorize(text).yellow());
void printMagenta(String text) => stdout.write(Colorize(text).lightMagenta());
void printRed(String text) => stdout.write(Colorize(text).red());
