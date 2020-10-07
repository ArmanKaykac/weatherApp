//import 'dart:html';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherapp/GetLocation.dart';
import 'GetLocation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';



void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   
  


  int temperature;
  var minTemps16 = new List(16);
  var maxTemps16 = new List(16);
  var icForDays16 = new List(16);
  var minTemps = new List(5);
  var maxTemps = new List(5);
  var icForDays = new List(5);
  String location = "istanbul";
  String searchApi =  "https://www.metaweather.com/api/location/search/?query=";
  int woeid = 2344116;
  String woeidLocation = "https://www.metaweather.com/api/location/";
  String weather = "clear";
  String ic = ""; 

  /*String apiTest2 = "api.openweathermap.org/data/2.5/weather?q=";
  String apiDevam = "&appid=";
  String api = "9fee112fc3cf7e30b14f3a020ea5a348";*/

  String city="istanbul";
  String baslangic(){
    Getlocation loc = Getlocation();
    
    city = loc.getCurrentLocation().toString();
    return city;
  }

  void fetchDays()async{
    var today = new DateTime.now();
    String apivol2 = "https://api.weatherbit.io/v2.0/forecast/daily?city=="+ location+ "&key=";
    String apiKey = "3a63143cb4604793965853f098134790";
    for (var i=0;i<5;i++){
      // düzgün veri vermeyen api
     /* var forIcon = await http.get(woeidLocation + woeid.toString() + "/" + new DateFormat('y/M/d').format(today.add(new Duration(days: i + 1))).toString());
      var res = json.decode(forIcon.body);
      print("1");
      var data = res;*/

      var locationDayResult = await http.get(apivol2 + apiKey );
      var res2 = json.decode(locationDayResult.body);
      print("2");
      var dataForTemp = res2;
      setState(() {
        print("3");
      minTemps[i] = dataForTemp["data"][i]["min_temp"].round();
      maxTemps[i] = dataForTemp["data"][i]["max_temp"].round();
      icForDays[i] = dataForTemp["data"][i]["weather"]["icon"].toString();
    });

    }
  }

  void fetchDays16()async{
    var today = new DateTime.now();

    String apivol2 = "https://api.weatherbit.io/v2.0/forecast/daily?city=="+ location+ "&key=";
    String apiKey = "3a63143cb4604793965853f098134790";
    for (var i=0;i<16;i++){
      var locationDayResult = await http.get(apivol2 + apiKey );
      var res = json.decode(locationDayResult.body);
      var data = res;
      setState(() {

      minTemps16[i] = data["data"][i]["min_temp"].round();
      maxTemps16[i] = data["data"][i]["max_temp"].round();
      icForDays16[i] = data["data"][i]["weather"]["icon"].toString();
      
    });

    }
  }

  initState() {
    // TODO: implement initState
    super.initState();
    
    apiSearch(city);
    getLocation();
    fetchDays();
    fetchDays16();
  }

  /*void apiTest(String apiTest2,String apiDevam)async{
    //var searchResult = await http.get(apiTest2+location+apiDevam+api);
    var res = json.decode(searchResult.body)[0];
    setState(() {
      location = res["main"];
      woeid = res["woeid"];
    });
  }*/


  void apiSearch(String apiAddOn) async {
    var searchResult = await http.get(searchApi + apiAddOn);
    var res = json.decode(searchResult.body)[0];
    setState(() {
      location = res["title"];
      woeid = res["woeid"];
    });
  }



  void getLocation()async{
    var locationResult = await http.get(woeidLocation + woeid.toString());
    var res = json.decode(locationResult.body);
    var consolidatedWeather = res["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      ic = data["weather_state_abbr"];
    });
  }

  void textFieldCheck(String input)async{
    /*//await apiTest(apiTest2,apiDevam);*/
    await apiSearch(input);
    await getLocation();
    await fetchDays();
    await fetchDays16();
  }


  @override
  Widget build(BuildContext context) {
    Getlocation loc = Getlocation();
    loc.getCurrentLocation();
    return MaterialApp(
      localizationsDelegates: [
   // ... app-specific localization delegate[s] here
   GlobalMaterialLocalizations.delegate,
   GlobalWidgetsLocalizations.delegate,
   GlobalCupertinoLocalizations.delegate,
 ],
 supportedLocales: [
    const Locale('en', ''),
    const Locale('he', ''),
    const Locale('tr', ''),
    const Locale.fromSubtags(languageCode: 'zh'),
    // ... other locales the app supports
  ],
  debugShowCheckedModeBanner: false,
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/$weather.png'),
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
              )
          ),
          child: temperature ==null ? Center(
            child: CircularProgressIndicator()
          ):Scaffold(
            appBar: AppBar(actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right:20.0),
                child: GestureDetector(
                  onTap: ()async{
                    String city= loc.getCurrentLocation().toString();
                    await apiSearch(city);
                    await getLocation();
                    await fetchDays();
                    await fetchDays16();
                  },
                  child: Icon(Icons.location_city_rounded,size: 36.0),
                ),
              )
            ],
            backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            backgroundColor: Colors.transparent,
            body: ListView(



              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input){
                              textFieldCheck(input);
                            },
                              style: TextStyle(color: Colors.white, fontSize: 25),
                              decoration: InputDecoration(
                                hintText: 'Şehir seçiniz..',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                                prefixIcon: Icon(
                                    Icons.search, color: Colors.white),
                              )
                          ),
                        ),
                      ]),
                ),
                 Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Center(child: Image.network("https://www.metaweather.com/static/img/weather/png/" + ic + ".png", width: 100,),

                      ),
                      Center(
                        child: Text(
                          temperature.toString() + ' ℃',
                          style: TextStyle(color: Colors.white, fontSize: 60.0),
                        ),
                      ),
                      Center(
                        child: Text(
                          location,
                          style: TextStyle(color: Colors.white, fontSize: 40.0),
                        ),
                      )
                    ],
                  ),
                ),

                Padding(
                   padding: const EdgeInsets.only(top:250.0, bottom: 16.0, left:16.0, right:16.0),
                   child: SingleChildScrollView(

                      scrollDirection: Axis.horizontal,
                      child: Row(

                        children: <Widget>[

                        for(var i =0 ; i<5; i++)
                          forecastElement5(i+1,icForDays[i], maxTemps[i], minTemps[i]),

                      ],
             ),
                    ),
                 ),


                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for(var i =0 ; i<16; i++)
                          forecastElement16(i+1 ,icForDays16[i],maxTemps16[i], minTemps16[i]),

                      ],
                    ),
                  ),
                )
              ],
            )

            ,
          ),
        )
    );
  }



Widget forecastElement5(dayCount, icForDays, maxTemp, minTemp){
  var time = new DateTime.now();
  var oneDayAdd = time.add(new Duration(days: dayCount));
  return Padding(
    padding: const EdgeInsets.only(left:8.0),
    child: Container(

      decoration: BoxDecoration(
        color: Color.fromRGBO(285, 212, 228, 0.2),
      borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(new DateFormat.E("tr_TR").format(oneDayAdd),
            style: TextStyle(color:Colors.white, fontSize:25),
            ),
            Text(
              new DateFormat.MMMd("tr_TR").format(oneDayAdd),
            style: TextStyle(color:Colors.white, fontSize:20),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom:16.0, top:16.0),
              child: Image.network(

                "https://www.weatherbit.io/static/img/icons/"+ icForDays+".png", width: 50,
                ),
            ),
              Text(
                maxTemp.toString() + ' ℃',
                        style: TextStyle(color: Colors.white, fontSize:20.0),
              ),
              Text(
                minTemp.toString() + ' ℃',
                        style: TextStyle(color: Colors.white, fontSize:20.0),
              ),
            ],

        ),
      ),
    ),
  );


  
    
  
}
Widget forecastElement16(dayCount,icForDays16, maxTemp16, minTemp16){
  var time = new DateTime.now();
  var oneDayAdd = time.add(new Duration(days: dayCount));
  return Padding(
    padding: const EdgeInsets.only(left:8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(285, 212, 228, 0.2),
      borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(new DateFormat.E("tr_TR").format(oneDayAdd),
            style: TextStyle(color:Colors.white, fontSize:25),
            ),
            Text(
              new DateFormat.MMMd("tr_TR").format(oneDayAdd),
            style: TextStyle(color:Colors.white, fontSize:20),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom:16.0, top:16.0),
              child: Image.network(

                "https://www.weatherbit.io/static/img/icons/"+ icForDays16+".png", width: 50,
              ),
            ),


              Text(
                maxTemp16.toString() + ' ℃',
                        style: TextStyle(color: Colors.white, fontSize:20.0),
              ),
              Text(
                minTemp16.toString() + ' ℃',
                        style: TextStyle(color: Colors.white, fontSize:20.0),
              ),
            ],

        ),
      ),
    ),
  );
}
}