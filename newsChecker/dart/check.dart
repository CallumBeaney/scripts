import 'dart:io';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/error.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:hackernews_api/hackernews_api.dart';

// Future<List<Source>> _sources = _newsAPI.getSources();
// https://newsapi.org/v2/sources?x=y&apiKey=34984eeaaece433c812780af807e3dda

void main() async {
  clearTerminal();
  stdout.write('1. Hacker News\n2. Generic Tech News\n3. 日本ニュース\n4. 中国新闻\n');

  int? userChoice = null;
  while (userChoice == null || (userChoice > 4 || userChoice < 1)) {
    stdout.write('\nChoice: ');
    userChoice = int.parse(stdin.readLineSync()!);
  }

  print('if');
  if (userChoice == 1) {
    clearTerminal();
    int? storyType = null;
    stdout.write('1. Top Stories\n2. New Stories\n3. "Ask" Stories\n4. Job Stories\n');
    while (storyType == null || (storyType > 4 || storyType < 1)) {
      stdout.write('\nChoice: ');
      storyType = int.parse(stdin.readLineSync()!);
    }
    hackerNews(storyType);
  } else if (userChoice == 2) {
  } else if (userChoice == 3) {
  } else if (userChoice == 4) {
  } else {}
}

void hackerNews(int choice) async {
  // Disable standard input echoing
  stdin.echoMode = false;

  // Disable standard input line mode
  stdin.lineMode = false;

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
              'ERROR: Invalid parameter "choice" erroneously passed to HackerNews constructor. Please raise an issue on Github.');
      }
    })(),
  );

  List<Story> stories = await news.getStories();

  if (stories.isEmpty) {
    stdout.writeln(
        'ERROR: Failed to fetch news article data. This may due to connectivity problems or API gateway issues.');
    exit(1);
  }

  // clearTerminal();

  for (Story story in stories.reversed) {
    print(story.title);
    print(story.url);
    // printClickableLink('READ', story.url);
    print('\n');
  }

  // autoScrollUpwards();
}

void newsAPI() async {
  NewsAPI _newsAPI = NewsAPI('34984eeaaece433c812780af807e3dda');
  DateTime now = DateTime.now();
  Duration oneWeek = Duration(days: 5);
  DateTime oneWeekAgo = now.subtract(oneWeek);

  // Future<List<Source>> _sources = _newsAPI.getSources();
  // print(_sources);

  List<Article>? engTechArticles;
  List<Article>? ftzTechArticles;

  try {
    // List<Article> chineseTechArticles = await _newsAPI.getTopHeadlines(
    //   category: 'technology',
    //   country: 'cn',
    //   // query: '-AI',
    //   pageSize: 8,
    // );

    // List<Article> japaneseTechArticles = await _newsAPI.getTopHeadlines(
    //   category: 'technology',
    //   country: 'jp',
    //   // query: '-AI',
    //   pageSize: 3,
    // );

    // List<Article> articleList = await _newsAPI.getEverything(
    //   sources: 'bbc-news,',
    //   from: oneWeekAgo,
    //   to: now,
    // );
    // ftzTechArticles = await _newsAPI.getTopHeadlines(
    //   country: 'tw',
    //   category: 'technology',
    //   pageSize: 4,
    // );

    engTechArticles = await _newsAPI.getEverything(
      sources: 'hacker-news',
      query: '-apple -AI -gpt -twitter -fintech',
      // sortBy: 'relevancy',
      // from: oneWeekAgo,
      // to: now,
    );
  } catch (e) {
    if (e is ApiError) {
      print('ERROR: $e.message');
    } else {
      print('Unexpected error: $e');
    }
  }

  for (Article a in engTechArticles!) {
    stdout.write('\n${a.title}\nBY: ${a.author}\n');
    printClickableLink('READ\n', a.url!);

    if (a.description != null) {
      stdout.write('INFO:\t${a.description}\n\n');
    }

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
  if (Platform.isMacOS) {
    stdout.write('\x1B[2J\x1B[0;0H');
  }
}

void briefPause() async {
  await Future.delayed(Duration(milliseconds: 475));
}

void moveToPosition(int row, int column) {
  final positionCode = '\x1B[${row};${column}H';
  print(positionCode);
}
