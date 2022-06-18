import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

import './result.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  Future<Map<String, dynamic>> httpRequestGet(
      String urlStr, Map? headersMap) async {
    var url = Uri.parse(urlStr);
    var request = http.Request('GET', url);

    if (headersMap != null) {
      request.headers['Content-Type'] = headersMap['Content-Type'];
    }

    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    //Print the last 10 characters of the response body
    //print(response.body.substring(response.body.length - 15));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var temp = json.decode(response.body) as Map<String, dynamic>;

    return temp;
  }

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  //TextEditingController _ipController = TextEditingController();

  int startFrom = 0;
  List<Result> resultList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Engine"),
      ),
      body: Center(
        //show pop up to enter ip address
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () => search(_controller.text),
                    child: const Text("Search")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void search(String query) async {
    print("Searching for $query");
    var url = "http://10.0.2.2:8080/search?text=$query";
    var response = await widget.httpRequestGet(url, {
      'Content-Type': 'application/json',
    });

    //get request
    //var response = await http.get(Uri.parse(url));

    //print(response['search']);

    List<String> results = [];
    for (var result in response['search']) {
      results.add(result);
    }

    // List<String> results = [
    //   "https://www.google.com/",
    //   "https://www.youtube.com/",
    //   "https://www.youtube.com/",
    //   "https://www.youtube.com/",
    //   "https://www.youtube.com/",
    //   "https://www.youtube.com/"
    // ];
    // int resultsPerPage = 4;
    // int noOfPages = (results.length / resultsPerPage).ceil();

    // int inputSize = 0;
    // if (resultsPerPage > results.length) {
    //   inputSize = results.length;
    // } else {
    //   inputSize = resultsPerPage;
    // }

    // int endAt;
    // if (startFrom + inputSize > results.length) {
    //   endAt = results.length;
    // } else {
    //   endAt = startFrom + inputSize;
    // }

    // print("startFrom: $startFrom" + "endAt: $endAt");
    // resultList.clear();
    // for (int i = startFrom; i < inputSize; i++) {
    //   resultList.add(Result(
    //     URL: results[i],
    //     searchedWord: query,
    //   ));
    // }
    resultList.clear();
    for (int i = 0; i < results.length; i++) {
      resultList.add(Result(
        URL: results[i],
        searchedWord: query,
      ));
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (bCtx) {
          return Container(
            height: double.infinity,
            child: Column(children: <Widget>[
              const SizedBox(height: 20),
              ListTile(
                title: Text("Search for $query"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: resultList.length,
                  //physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (bCtx, index) {
                    return resultList[index];
                  },
                ),
              ),
              //buttons for each page
              const Spacer(),
            ]),
          );
        });
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
