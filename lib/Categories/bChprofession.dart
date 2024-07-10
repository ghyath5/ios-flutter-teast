import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'cChtype.dart';

class Profession extends StatefulWidget {
  final String catid;
  const Profession({super.key, required this.catid});

  @override
  State<Profession> createState() => _ProfessionState();
}

class _ProfessionState extends State<Profession> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _adNames = [];
  List<DocumentSnapshot> _professionDocs = [];
  int _currentIndex = 0;
  bool _isLoadingAds = true;
  bool _isLoadingProfessions = true;

  @override
  void initState() {
    super.initState();
    _fetchAds();
    _fetchProfessions();
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

  Future<void> _fetchProfessions() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.catid)
          .collection("profession")
          .get();
      setState(() {
        _professionDocs = querySnapshot.docs;
        _isLoadingProfessions = false;
      });
    } catch (e) {
      print("Error fetching professions: $e");
      setState(() {
        _isLoadingProfessions = false;
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
          child: Text("اختيار المهنة"),
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
                if (_isLoadingProfessions)
                  Center(child: CircularProgressIndicator())
                else if (_professionDocs.isEmpty)
                  Center(child: Text("No professions available"))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: _professionDocs.length,
                    itemBuilder: (context, i) {
                      final professionDoc = _professionDocs[i];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => Type(
                                  catid: widget.catid,
                                  profid: professionDoc.id,
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
                                  professionDoc['name'],
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
