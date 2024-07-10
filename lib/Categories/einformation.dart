import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class Information extends StatefulWidget {
  final String typeid;
  final String profid;
  final String catid;
  final String peoid;
  final String namepeo;

  const Information({
    super.key,
    required this.typeid,
    required this.profid,
    required this.catid,
    required this.peoid,
    required this.namepeo,
  });

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoadingInfo = true;
  Map<String, dynamic>? _infoData;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.catid)
          .collection("profession")
          .doc(widget.profid)
          .collection("type")
          .doc(widget.typeid)
          .collection("people")
          .doc(widget.peoid)
          .collection("info")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _infoData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
          _isLoadingInfo = false;
        });
      } else {
        setState(() {
          _isLoadingInfo = false;
        });
      }
    } catch (e) {
      print("Error fetching info: $e");
      setState(() {
        _isLoadingInfo = false;
      });
    }
  }

  void _launchCall(String phone) async {
    String url = "tel:$phone";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchWhatsApp(String whats) async {
    String url = "https://wa.me/$whats";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchInsta(String insta) async {
    String url = "$insta";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchLocation(String location) async {
    String url = Uri.encodeFull(
        "https://www.google.com/maps/search/?api=1&query=$location");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchFacebook(String facebook) async {
    String url = "$facebook";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoadingInfo
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundImage: NetworkImage(_infoData?['imageUrl'] ??
                            'https://via.placeholder.com/150'),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _infoData?['name'] ?? 'غير متوفر...',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _infoData?['joptitle'] ?? 'غير متوفر...',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      InkWell(
                        onTap: () {
                          _launchCall(_infoData?['phonenum'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          elevation: 0,
                          child: ListTile(
                            leading:
                                Icon(Icons.call, color: Colors.greenAccent),
                            title: GestureDetector(
                              child: Text(
                                  "${_infoData?['phonenum'] ?? 'غير متوفر...'}"),
                            ),
                            subtitle: Text(
                              "رقم الهاتف للاتصال المباشر",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchWhatsApp(
                              _infoData?['whatsnum'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: Image.network(
                                  "https://img.icons8.com/?size=100&id=16713&format=png&color=000000"),
                            ),
                            title: GestureDetector(
                              child: Text(
                                  _infoData?['whatsnum'] ?? 'غير متوفر...'),
                            ),
                            subtitle: Text(
                              "رقم الواتس اب المباشر",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchLocation(
                              _infoData?['location'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: Icon(Icons.location_on,
                                color: Colors.redAccent),
                            title: GestureDetector(
                              child: Text(
                                  _infoData?['location'] ?? 'غير متوفر...'),
                            ),
                          ),
                        ),
                      ),
                    
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        child: ListTile(
                          leading: Icon(Icons.school, color: Colors.blueAccent),
                          title: Text(
                              _infoData?['certificates'] ?? 'غير متوفر...'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchInsta(_infoData?['insta'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: SizedBox(
                              child: Image.network(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Instagram_logo_2022.svg/1200px-Instagram_logo_2022.svg.png"),
                              height: 15.h,
                              width: 15.w,
                            ),
                            title: GestureDetector(
                              child: Text('حساب الانستغرام'),
                            ),
                            subtitle: Text(
                              _infoData?['insta'] != null
                                  ? _infoData!['insta']
                                  : 'غير متوفر...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchInsta(
                              _infoData?['facebook'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: SizedBox(
                              child: Image.network(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Facebook_f_logo_%282019%29.svg/1200px-Facebook_f_logo_%282019%29.png"),
                              height: 15.h,
                              width: 15.w,
                            ),
                            title: GestureDetector(
                              child: Text('حساب الفيسبوك '),
                            ),
                            subtitle: Text(
                              _infoData?['facebook'] != null
                                  ? _infoData!['facebook']
                                  : 'غير متوفر...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
