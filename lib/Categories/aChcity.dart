import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalel/Categories/bChprofession.dart';
import 'package:dalel/auth/authpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> _fetchAdNames() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('customad').get();
      return querySnapshot.docs.map((doc) => doc['text'] as String).toList();
    } catch (e) {
      print("Error fetching ad names: $e");
      return [];
    }
  }

  Future<List<DocumentSnapshot>> _fetchCityNames() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('categories').get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching city names: $e");
      return [];
    }
  }

  List<Widget> generateTextTiles(List<String> adNames) {
    return adNames.map((name) {
      return Container(
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10.0),
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
          child: Text("اختيار المدينة"),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.bottomSlide,
                  title: 'تنبيه',
                  desc: 'هل تريد تسجيل الخروج من التطبيق',
                  btnOkOnPress: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAll(AuthPage());
                  },
                  btnCancelOnPress: () {},
                ).show();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: ListView(
        children: [
          FutureBuilder<List<String>>(
            future: _fetchAdNames(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error fetching ads"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No ads available"));
              } else {
                return SizedBox(
                  width: double.infinity,
                  height: 100.h,
                  child: CarouselSlider(
                    items: generateTextTiles(snapshot.data!),
                    options: CarouselOptions(
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 2.0,
                    ),
                  ),
                );
              }
            },
          ),
          SizedBox(height: 10.h),
          FutureBuilder<List<DocumentSnapshot>>(
            future: _fetchCityNames(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error fetching cities"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No cities available"));
              } else {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final catdoc = snapshot.data![i];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => Profession(catid: catdoc.id));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.blueAccent),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 10.h),
                              Text(
                                catdoc['name'],
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
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
