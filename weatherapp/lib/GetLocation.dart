import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';


class Getlocation{
  double latitude;
  double longitude;
  String city;
  //Get current location
  Future<String> getCurrentLocation() async{
    try{
      Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;

      city = await getCityName(position.latitude, position.longitude);
      
      print(city);
      print(position);
      return city;
    }catch(e){
      print(e);
    }
  }

  //Get city name
  Future<String> getCityName(double lat, double lon) async{
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lon);
    print('city name is: ${placemark[0].administrativeArea}');
    return placemark[0].administrativeArea;
  }
}


