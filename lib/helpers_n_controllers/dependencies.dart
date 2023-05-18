import 'package:e_commerce/helpers_n_controllers/restaurants_controller.dart';
import 'package:get/get.dart';


Future<void> init() async {
  //controllers
  Get.lazyPut(() => restaurants_controller());

}