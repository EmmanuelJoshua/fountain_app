import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:content_resolver/content_resolver.dart';
import 'package:opmlparser/opmlparser.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('app.channel.shared.data');
  String dataShared = '';
  Future<Opml>? podcastData;

  @override
  void initState() {
    super.initState();
    getDataFromIntent();
  }

  ///Get Data from Intent and URI
  void getDataFromIntent() async {
    var intentURI = await platform.invokeMethod('getSharedURI');

    //Check if Intent is null
    if (intentURI == null) return;

    final data = await ContentResolver.resolveContent(intentURI);

    //Decode UTF data to String
    String xmlContent = Utf8Decoder().convert(data);

    //Find the first index of the OPML tag, for OPML files embedded in XML
    int indexOfOPML = xmlContent.indexOf('<opml');

    setState(() {
      dataShared = xmlContent.substring(indexOfOPML, xmlContent.length);
    });
  }

  ///Parse OPML data, and return as Future
  Future<Opml?> getPodcastData() async {
    Opml? podcastData;
    if (dataShared != '') {
      podcastData = Opml.parse(dataShared);
    } else {
      podcastData = Opml.parse('<opml></opml>');
    }

    return podcastData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Imported Podcasts',
          style: TextStyle(
            fontSize: 20,
            fontFamily: Theme.of(context).textTheme.headline1!.fontFamily,
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder(
        future: getPodcastData(),
        builder: (context, AsyncSnapshot<Opml?> snapshot) {
          Widget mainWidget;
          if (snapshot.data == null) {
            mainWidget = Center(
              child: Text(
                'No Imported Podcast',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else {
            String title = snapshot.data!.title.toString();
            List<OpmlItem>? items = snapshot.data!.items;

            mainWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildPodcastList(items),
              ],
            );
          }

          return mainWidget;
        },
      ),
    );
  }

  ///Build podcast list
  Widget _buildPodcastList(List<OpmlItem>? items) {
    int listLength = 0;
    bool isOutlineFeed = true;

    if (items![0].text != 'feeds') {
      listLength = items.length;
      isOutlineFeed = false;
    } else if (items[0].text == 'feeds') {
      listLength = items[0].nesteditems!.length;
      isOutlineFeed = true;
    }

    return Expanded(
      child: ListView.separated(
        itemCount: listLength,
        separatorBuilder: (contex, index) => SizedBox(
          height: 10,
        ),
        itemBuilder: (context, index) {
          String title;
          String subtitle;
          if (isOutlineFeed) {
            title = items[0].nesteditems![index].text.toString();
            subtitle = items[0].nesteditems![index].xmlUrl.toString();
          } else {
            title = items[index].text.toString();
            subtitle = items[index].xmlUrl.toString();
          }
          return ListTile(
            tileColor: Colors.grey,
            leading: CircleAvatar(
                child: Icon(
              Icons.headset_rounded,
            )),
            title: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
