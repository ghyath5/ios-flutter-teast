import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalel/Categories/einformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class People extends StatefulWidget {
  final String typeid;
  final String profid;
  final String catid;
  const People(
      {super.key,
      required this.profid,
      required this.catid,
      required this.typeid});

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _adNames = [];
  List<DocumentSnapshot> _peopleDocs = [];
  int _currentIndex = 0;
  bool _isLoadingAds = true;
  bool _isLoadingPeople = true;

  @override
  void initState() {
    super.initState();
    _fetchAds();
    _fetchPeople();
  }

  Future<void> _fetchAds() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('customad').get();
      List<String> adNames = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('text') && data['text'] is String) {
          adNames.add(data['text']);
        } else {
          print("Missing or invalid 'text' field in document: ${doc.id}");
        }
      }
      setState(() {
        _adNames = adNames;
        _isLoadingAds = false;
      });
    } catch (e) {
      print("Error fetching ads: $e");
      setState(() {
        _isLoadingAds = false;
      });
    }
  }

  Future<void> _fetchPeople() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.catid)
          .collection("profession")
          .doc(widget.profid)
          .collection("type")
          .doc(widget.typeid)
          .collection("people")
          .get();

      List<DocumentSnapshot> peopleDocs = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('name') && data['name'] is String) {
          peopleDocs.add(doc);
        } else {
          print("Missing or invalid 'name' field in document: ${doc.id}");
        }
      }

      setState(() {
        _peopleDocs = peopleDocs;
        _isLoadingPeople = false;
      });
    } catch (e) {
      print("Error fetching people: $e");
      setState(() {
        _isLoadingPeople = false;
      });
    }
  }

  List<Widget> generateTextTiles() {
    return _adNames.map((name) {
      return Container(
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10.0.r),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("اختيار نوع المهنة"),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                if (_isLoadingAds)
                  Center(child: CircularProgressIndicator())
                else
                  InkWell(
                    onTap: () {},
                    child: SizedBox(
                      width: double.infinity,
                      height: 100.h, // تعديل ارتفاع الـ CarouselSlider
                      child: CarouselSlider(
                        items: generateTextTiles(),
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 2.0, // تعديل نسبة العرض إلى الارتفاع
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 10.h),
                if (_isLoadingPeople)
                  Center(child: CircularProgressIndicator())
                else if (_peopleDocs.isEmpty)
                  Center(child: Text("No people available"))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: _peopleDocs.length,
                    itemBuilder: (context, i) {
                      final data =
                          _peopleDocs[i].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Get.to(Information(
                              typeid: widget.typeid,
                              profid: widget.profid,
                              catid: widget.catid,
                              peoid: _peopleDocs[i].id,
                              namepeo: data['name'],
                            ));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0.r),
                              side: BorderSide(color: Colors.blueAccent),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10.h),
                                Text(
                                  data['name'],
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.blueAccent),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
