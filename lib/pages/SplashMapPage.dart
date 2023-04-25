import 'dart:convert';
import 'package:app_ipue/pages/dashborad.dart';
import 'package:app_ipue/pages/map_iglesias.dart';
import 'package:app_ipue/utilities/widgets_utils.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_ipue/utilities/styles_utils.dart';

class SplashMapPage extends StatefulWidget {
  const SplashMapPage({super.key});
  @override
  State<SplashMapPage> createState() => _SplashMapPageState();
}

class _SplashMapPageState extends State<SplashMapPage> {
  final box = GetStorage();
  String location = 'Null, Press Button';
  String address = 'search';

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  Future<void> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    box.write('myAddress', address);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();

    box.write('myLatitud', position.latitude.toString());
    box.write('myLongitud', position.longitude.toString());

    getAddressFromLatLong(position);
    print("Vslor: ");
    print(position.latitude.toString());

    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WidgetUtils.ipueFondo(),
          _panelImage(),
          _panelTextos(),
          _btnGetStarted(),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////
  Widget _panelImage() {
    return Positioned(
      top: 180,
      left: 20,
      right: 20,
      child: Column(
        children: const [
          Image(
            image: AssetImage("assets/images/splash.png"),
            width: 400,
          ),
        ],
      ),
    );
  }

  Widget _panelTextos() {
    return Positioned(
        bottom: 190.0,
        left: 40,
        right: 40,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "¡Encuentra y únete a tu círculo ahora!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: IpueColors.cBlanco,
                  fontSize: 30.0,
                  fontFamily: "Roboto",
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Solución para que todas las personas apasionadas encuentren amigos con la misma pasión en el mundo.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: IpueColors.cBlanco,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _btnGetStarted() {
    return Positioned(
      bottom: 60,
      left: 40,
      right: 40,
      child: GestureDetector(
        onTap: () {
          login();
          Get.to(const MapIglesias());
        },
        child: Container(
          decoration: const BoxDecoration(
            color: IpueColors.cPrimario,
            boxShadow: [
              BoxShadow(
                color: IpueColors.cSecundario,
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              )
            ],
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              bottom: 20.0,
            ),
            child: Center(
              child: Text(
                "EMPEZAR",
                style: TextStyle(
                  color: IpueColors.cBlanco,
                  fontFamily: "Roboto",
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    try {
      Map data = {"email": "fericor@gmail.com", "password": "vekg80sy"};
      var body = json.encode(data);

      var url = Uri.parse('${IpueColors.urlHost}/login.php');
      var response = await http.post(url, body: body);
      var decodeJson = jsonDecode(response.body);

      if (decodeJson["success"] == 1) {
        box.write('token', decodeJson["token"]);
      }
    } finally {}
  }
  ///////////////////////////////////////////////////
}
