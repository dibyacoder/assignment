import 'dart:convert';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class restaurants_controller extends GetxController {
  var result;
  List<Map<String, dynamic>> _hotel = [];
  List<Map<String, dynamic>> _searchedhotel = [];

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getrestro(String lat, String lng) async {
    final apiUrl =
        Uri.parse('https://theoptimiz.com/restro/public/api/get_resturants');
    try {
      final response = await http.post(
        apiUrl,
        body: {
          'lat': lat,
          'lng': lng,
        },
      );

      if (response.statusCode == 200) {
        print("got products");
        //print(response.body);
        result = jsonDecode(response.body);
        _isLoaded = true;
        update();
      } else {
        print('could not get subcategory');
      }
      for (var i = 0; i < result.length; i++) {
        _hotel.add({
          'name': result["data"][i]["name"],
        });
      }
      print(_hotel);
    } catch (e) {
      print('Error: $e');
    }
  }

  void updatelist(String val) {
    if (val.isEmpty) {
      _searchedhotel = _hotel;
    } else {
      _searchedhotel = _hotel
          .where((element) => element["name"]
              .toString()
              .toLowerCase()
              .contains(val.toString().toLowerCase()))
          .toList();
      
    }
    update();
  }
}
