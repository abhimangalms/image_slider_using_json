import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_slider_using_json/api_calls.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: true,
    title: 'Carousel Pro',
    home: CarouselDemo(),
  ));
}

class CarouselDemo extends StatefulWidget {
  CarouselDemo() : super();

  final String title = "Carousel Demo";

  @override
  CarouselDemoState createState() => CarouselDemoState();
}

class CarouselDemoState extends State<CarouselDemo> {
  List imgsList;
  var imageData = [];
  bool isLoaded = false;

  @override
  void initState() {
    callApi().then((imgListUrl) {
      //calling mathod using future
      setState(() {
        imageData = imgListUrl;
        isLoaded = true;
        print(imgListUrl);
      });
    });
    super.initState();
  }

  CarouselSlider carouselSlider;
  int _current = 0;

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: isLoaded
            ? centerSliderContainer()
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  Future<List<dynamic>> callApi() async {
    ApiCalls apiCalls = new ApiCalls();
    List imagesUrl = await apiCalls.getImageSliders();
//    print(imagesUrl);
    return imagesUrl;
  }

  Widget centerSliderContainer() {
    return Container(
      child: ConstrainedBox(
        constraints: BoxConstraints(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CarouselSlider(
              height: 300.0,
              initialPage: 0,
              autoPlay: true,
              reverse: false,
              enableInfiniteScroll: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 2000),
              pauseAutoPlayOnTouch: Duration(seconds: 10),
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                });
              },
              items: imageData.map((imgUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Column(
                      children: <Widget>[
                        new Stack(
                          children: <Widget>[
                            new Card(
                              child: Container(
                                width: 500,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Expanded(
                                        child: Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      new Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(5.0),
                                        child: Text(
                                          "Movie name",
                                          style: TextStyle(fontSize: 12.0),
                                        ),
                                      )
                                    ]),
                              ),
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 8,
                            ),
                          ],
                        ),
//                        new Container(
//                          alignment: Alignment.bottomLeft,
//                          child: Text(
//                            "Movie one",
//                            style: TextStyle(
//                                fontSize: 14.0, color: Colors.black),
//                          ),
//                        )
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
