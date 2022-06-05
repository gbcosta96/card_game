import 'dart:math';
import 'package:get/get.dart';

class Dimensions{
 
  static const double loginWidth = 70.0; // %
  static const double loginLandscapingWidth = 50.0; // %
  static const double loginSpacingHeight = 5.0; // %
  static const double inputPaddingHeight = 3.0; // %
  static const double inputPrefixWidth = 10.0; // %
  static const double inputHeight = 12.0; // %
  static const double buttonPaddingHeight = 10.0;

  static const double fontSize = 20;
  static const double fontSizeLeaderboard = 2; // %


  static double height(double height){
    return Get.context!.height*height/100.0;
  } 

  static double width(double width){
    return Get.context!.width*width/100.0;
  }

  static double smallest(double size){
    return min(height(size), width(size));
  }

  static double greatest(double size){
    return max(height(size), width(size));
  }

  
}