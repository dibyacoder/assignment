import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:e_commerce/widgets/big_font.dart';
import 'package:e_commerce/widgets/dimensions.dart';
import 'package:e_commerce/widgets/small_font.dart';
import 'package:e_commerce/widgets/constants.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'helpers_n_controllers/restaurants_controller.dart';

class Home_page extends StatefulWidget {
  const Home_page({Key? key}) : super(key: key);

  @override
  State<Home_page> createState() => _Home_pageState();
}

final searchController = TextEditingController();
String search = "";
String searchQuery = '';

class _Home_pageState extends State<Home_page> {
  String currentAddress = 'My Address';
  late Position currentposition;

  Future _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentposition = position;
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  bool changebutton = false;
  final List<bool> selectedItems = List.generate(5, (_) => false);
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBGColor,
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Colors.white,
                Color.fromARGB(255, 243, 223, 230),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            )),
            padding: EdgeInsets.all(dimensions.size15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: dimensions.size10 / 3,
                ),
                GestureDetector(
                  onTap: () {
                    _determinePosition();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on,
                          size: dimensions.size20, color: Colors.black),
                      SmallFont(
                        text: currentAddress,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: dimensions.size10,
                ),
                SmallFont(
                  text: "Stories",
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(
                  height: dimensions.size10,
                ),
                Container(
                  height: dimensions.size45 * 2.4,
                  color: Color.fromARGB(255, 243, 223, 230),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, position) {
                      return _buildCategoriesItem(position);
                    },
                  ),
                ),
                SizedBox(
                  height: dimensions.size20,
                ),
                GetBuilder<restaurants_controller>(builder: (controller) {
                  return Container(
                    height: dimensions.size20 * 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(dimensions.size20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(
                              0, 3), // changes the shadow direction vertically
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(fontSize: 17),
                        hintText: 'Search Food Items',
                        prefixIcon: Container(
                          child: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(dimensions.size10),
                      ),
                      onChanged: (value) {
                        controller.updatelist(value);
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  );
                }),
                SizedBox(
                  height: dimensions.size30,
                ),
                Container(
                  height: dimensions.size20 * 2,
                  color: Color.fromARGB(255, 245, 234, 238),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedItems.length,
                    itemBuilder: (context, position) {
                      return _buildMenuItem(position);
                    },
                  ),
                ),
                SizedBox(
                  height: dimensions.size15,
                ),
                SmallFont(
                  text: "Nearby Restaurant",
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(
                  height: dimensions.size10,
                ),
                GetBuilder<restaurants_controller>(builder: (controller) {
                  return controller.isLoaded
                      ? Container(
                          width: double.maxFinite,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.result["data"].length,
                            itemBuilder: (context, position) {
                              return _buildDoctorsItem(
                                  position, controller.result);
                            },
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: dimensions.size10 * 15),
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Color.fromARGB(255, 52, 43, 106),
                              size: 50,
                            ),
                          ),
                        );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsItem(int index, result) {
    
    return Stack(
      children: [
        GestureDetector(
          // onTap: () {
          //   Get.to(DocProfilePage(pageId: index));
          // },
          child: Container(
            height: dimensions.size20 * 8,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(dimensions.size15),
              color: const Color.fromARGB(255, 189, 217, 231),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(dimensions.size15),
              child: Image(
                image: NetworkImage(result["data"][index]["primary_image"]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // child: Image.asset(
              //   "assets/images/dominos.png",
              //   fit: BoxFit.cover,
              //   width:
              //       double.infinity, // Ensure the image takes up the full width
              //   height: double.infinity,
              // ),
            ),
          ),
        ),
        Positioned(
          bottom: dimensions.size15,
          left: 0,
          right: 0,
          child: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(
                          0, 3), // changes the shadow direction vertically
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(dimensions.size15),
                      bottomRight: Radius.circular(dimensions.size15))),
              height: dimensions.size20 * 2.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: dimensions.size10 / 3,
                      ),
                      BigFont(text: result["data"][index]["name"]),
                      SmallFont(
                        text: result["data"][index]["tags"],
                        size: dimensions.size10 / 1.1,
                      ),
                    ],
                  ),
                  
                  Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/percents.png",
                            height: dimensions.size10 * 3,
                            width: dimensions.size10 * 3,
                          ),
                          BigFont(
                            text: result["data"][index]["discount"] +
                                "% FLAT OFF",
                            color: Colors.red,
                            size: dimensions.size10 * 1.2,
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: dimensions.size10/1.1,
                          ),
                          SizedBox(
                            width: dimensions.size10 / 2,
                          ),
                          SmallFont(
                            text: result["data"][index]["distance"] + " Meters Away",
                            size: dimensions.size10 / 1.1,
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )),
        ),
        Positioned(
          bottom: dimensions.size100 / 1.5,
          left: dimensions.size110 * 2.6,
          right: dimensions.size10 * 1.3,
          child: Container(
            height: dimensions.size25,
            decoration: BoxDecoration(
                color: Color(0xFF4CBB17),
                borderRadius:
                    BorderRadius.all(Radius.circular(dimensions.size10 / 3))),
            child: Row(
              children: [
                SizedBox(
                  width: dimensions.size10 / 2,
                ),
                SmallFont(
                  text: result["data"][index]["rating"],
                  color: Colors.white,
                ),
                SizedBox(
                  width: dimensions.size10 / 3,
                ),
                Icon(
                  Icons.star,
                  size: dimensions.size10,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesItem(int index) {
    return Stack(
      children: [
        GestureDetector(
          child: Container(
            height: dimensions.size30 * 3.5,
            width: dimensions.size30 * 2.6,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(dimensions.size10),
              color: const Color.fromARGB(255, 189, 217, 231),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(dimensions.size10),
                child: Image.asset(
                  "assets/images/dominos.png",
                  fit: BoxFit.cover,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedItems[index] = !selectedItems[index];
              selectedIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: dimensions.size20 * 1.7,
            width: selectedIndex == index
                ? dimensions.size20 * 3.5
                : dimensions.size20 * 2.5,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(dimensions.size20),
              color: selectedIndex == index ? Colors.red[600] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset:
                      Offset(0, 3), // changes the shadow direction vertically
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(dimensions.size20),
                child: Icon(Icons.food_bank_outlined)),
          ),
        ),
      ],
    );
  }
}
