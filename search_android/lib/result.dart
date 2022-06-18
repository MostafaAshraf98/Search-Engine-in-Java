import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:html/parser.dart';

import 'package:http/http.dart' as http;

class Result extends StatefulWidget {
  Result({Key? key, required String URL, required String searchedWord})
      : _URL = URL,
        _searchedWord = searchedWord,
        super(key: key);

  String _URL, _searchedWord;

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  @override
  Widget build(BuildContext context) {
    var url = Uri.parse(widget._URL);
    var response = http.get(url);
    return FutureBuilder(
      future: response,
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          var document = parse(snapshot.data!.body);
          var title = document.querySelector('title');
          var body = document.querySelector('body');

          // regular expression:
          RegExp re = RegExp(r"(\w|\s|,|')+[。.?!]*\s*");

          // get all the matches:
          Iterable matches = re.allMatches(body!.text);

          // loop over the matches:
          List<String> matchesList = [];
          for (var match in matches) {
            matchesList.add(match.group(0));
          }
          // loop over the matches:
          //printing matched list
          // for (var match in matchesList) {
          //   print(match);
          // }
          String des = widget._searchedWord;
          for (var i = 0; i < matchesList.length; i++) {
            if (matchesList[i].contains(widget._searchedWord)) {
              des = matchesList[i];
              break;
            }
          }
          //print("description " + des);
          return InkWell(
            onTap: () {
              _launchUrl(Uri.parse(widget._URL));
              setState(() {});
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(style: TextStyle(color: Colors.blue), title!.text),
                  //URl
                  Text(style: TextStyle(color: Colors.green), widget._URL),
                  //Description
                  Text(des),
                  //Text(matches.length.toString()),
                ],
              ),
            ),
          );
        } else {
          return const Text('Loading...');
        }
      },
    );
  }

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }
}
