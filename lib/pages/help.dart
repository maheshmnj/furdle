import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furdle/exports.dart';
import 'package:furdle/utils/navigator.dart';
import 'package:furdle/utils/settings_service.dart';
import 'package:furdle/utils/utility.dart';

class HelpPage extends StatelessWidget {
  HelpPage({Key? key}) : super(key: key);
  final String title = helpTitle;

  @override
  Widget build(BuildContext context) {
    String description = """
  Your goal is to guess a 5 letter word in N tries.
  N can be 4,5,6 based on the Difficulty level.
   - 4: Hard
   - 6: Medium (default)
   - 7: Easy
  
  Each guess must be a valid five-letter word. Hit the enter button to submit.
 
  After submitting each word, the color of the tiles will change to show how close your guess was to the word.
  """;

    const String case1 = 'The letter E is in the word and in the correct spot';
    const String case2 = 'The letter L is in the word but in the wrong spot.';
    const String case3 = 'The letter Y is not in the word at any spot';

    Widget subTitle(String subTitle,
        {double fontSize = 24, double vPadding = 8}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding),
        child: Text(
          subTitle,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontSize >= 20 ? FontWeight.w500 : FontWeight.normal),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(title),
          actions: [
            IconButton(
                onPressed: () {
                  popView(context);
                },
                icon: const Icon(Icons.close))
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: SettingsService.screenSize.width < 600
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(description,
                    style: const TextStyle(
                      fontSize: 16,
                    )),
              ),
              const Divider(),
              subTitle('Examples'),
              subTitle('Case 1', fontSize: 20),
              "GREAT".toWord(2),
              subTitle(case1, fontSize: 16),
              subTitle('Case 2', fontSize: 20),
              "PLANE".toWord(1, color: yellow),
              subTitle(case2, fontSize: 16),
              subTitle('Case 3', fontSize: 20),
              "DAISY".toWord(4, color: black),
              subTitle(case3, fontSize: 16),
              if (kIsWeb)
                Container(
                    alignment: Alignment.center,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(playStoreUrl);
                      },
                      child: Image.asset('assets/googleplay.png'),
                    )),
              subTitle('Report a bug', fontSize: 16),
              Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Column(
                    children: [
                      'Email'.toLink(onTap: () {
                        launchUrl(emailSource);
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                      'Github'.toLink(onTap: () {
                        launchUrl(sourceUrl);
                      })
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

extension WebLink on String {
  Widget toLink({Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        this,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          // decorationStyle: TextDecorationStyle.solid
        ),
      ),
    );
  }
}

extension ExampleWord on String {
  Widget toWord(int index, {double boxSize = 40, Color color = green}) {
    return Material(
      color: Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < length; i++)
          Container(
              height: boxSize,
              width: boxSize,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: Text(
                this[i].toUpperCase(),
                style: const TextStyle(
                    height: 1.1,
                    letterSpacing: 2,
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: i == index ? color : grey))
      ]),
    );
  }
}
