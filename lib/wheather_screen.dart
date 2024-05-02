import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:wheather_app/additional_info.dart';
import 'package:wheather_app/secrets.dart';
import 'package:wheather_app/wheather_forcast.dart';
import 'package:http/http.dart' as http;

class WheatherScreen extends StatefulWidget {
  const WheatherScreen({super.key});

  @override
  State<WheatherScreen> createState() => _WheatherScreenState();
}

class _WheatherScreenState extends State<WheatherScreen> {
 
 

  Future<Map<String,dynamic>>getCurrentWheather() async {
    try {
      String cityName = "Karachi";
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$wheatherApiKey"),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'unexpected error occur';
      }
       return data;
    
      
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather APP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                 
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:FutureBuilder(
        future: getCurrentWheather(),
        builder:(context, snapshot) {
          if(snapshot.connectionState ==ConnectionState.waiting){
            return const Center(
              child:  CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }
          final data=snapshot.data!;
          final getCurrentWheatherData=data['list'][0];

          final currentTemp=getCurrentWheatherData['main']['temp'];
          final currentSky = getCurrentWheatherData['weather'][0]['main'];
          final currentPressure=getCurrentWheatherData['main']['pressure'];
          final currentWindSpeed=getCurrentWheatherData['wind']['speed'];
          final currentHumidity=getCurrentWheatherData['main']['humidity'];
          return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    "$currentTemp k",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Icon(
                                    currentSky == "Clouds" || currentSky == "Rain"?
                                    Icons.cloud:
                                    Icons.sunny,
                                    size: 64,
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                   Text(
                                    currentSky,
                                    style: const TextStyle(
                                      fontSize: 30,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        
                    // wheather forecast
        
                    const SizedBox(height: 20),
                    const Text(
                      "Hourly Forecast",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(height: 120,
                      child: ListView.builder(
                        itemCount: 5,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context,index){
                          final hourlyForecast=data['list'][index+1];
                          final skyForecast =data['list'][index+1]['weather'][0]['main'];
                          final time=DateTime.parse(hourlyForecast['dt_txt'].toString(),);
                          return HourlyForcast(
                            icon: skyForecast == "Clouds"|| skyForecast=="Rain"?
                             Icons.cloud:
                             Icons.sunny, 
                            temperature: hourlyForecast['main']['temp'].toString(), 
                            time: DateFormat.j().format(time),
                            );
                        },
                      
                        ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Additional Information",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AddtionalInfo(
                          icon: Icons.water_drop,
                          label: "Humidity",
                          value: currentHumidity.toString(),
                        ),
                        AddtionalInfo(
                          icon: Icons.air,
                          label: "Wind Speed",
                          value: currentWindSpeed.toString(),
                        ),
                        AddtionalInfo(
                          icon: Icons.beach_access,
                          label: "Pressue",
                          value: currentPressure.toString(),
                        ),
                      ],
                    )
                  ],
                ),
              );
        },
      ),
    );
  }
}
