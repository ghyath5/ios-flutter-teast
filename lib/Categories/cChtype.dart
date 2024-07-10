import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'cChtype.dart';
import 'dChpeople.dart';

class Type extends StatefulWidget {
  final String profid;
  final String catid;
  const Type({super.key, required this.profid, required this.catid});

  @override
  State<Type> createState() => _TypeState();
}

class _TypeState extends State<Type> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _adNames = [];
  List<DocumentSnapshot> _typeDocs = [];
  int _currentIndex = 0;
  bool _isLoadingAds = true;
  bool _isLoadingTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchAds();
    _fetchTypes();
  }

  Future<void> _fetchAds() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('customad').get();
      List<String> adNames = [];
      for (var doc in querySnapshot.docs) {
        adNames.add(doc['text']);
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

  Future<void> _fetchTypes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.catid)
          .collection("profession")
          .doc(widget.profid)
          .collection("type")
          .get();
      setState(() {
        _typeDocs = querySnapshot.docs;
        _isLoadingTypes = false;
      });
    } catch (e) {
      print("Error fetching types: $e");
      setState(() {
        _isLoadingTypes = false;
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
                      height: 100.h,
                      child: CarouselSlider(
                        items: generateTextTiles(),
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 2.0,
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
                if (_isLoadingTypes)
                  Center(child: CircularProgressIndicator())
                else if (_typeDocs.isEmpty)
                  Center(child: Text("No Type available"))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: _typeDocs.length,
                    itemBuilder: (context, i) {
                      final people = _typeDocs[i];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Get.to(People(
                                profid: widget.profid,
                                catid: widget.catid,
                                typeid: people.id));
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
                                  people['name'],
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
