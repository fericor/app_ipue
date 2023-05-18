import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:app_ipue/models/iglesias_model.dart';
import 'package:app_ipue/utilities/styles_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapIglesias extends StatefulWidget {
  const MapIglesias({Key? key}) : super(key: key);

  @override
  State<MapIglesias> createState() => _MapIglesiasState();
}

class _MapIglesiasState extends State<MapIglesias>
    with TickerProviderStateMixin {
  final pageController = PageController();
  int selectedIndex = 0;

  late final MapController mapController;

  TextEditingController controlBuscar = TextEditingController();
  IglesiasModel listaIglesias =
      IglesiasModel.fromJson({"error": true, "iglesias": []});

  final box = GetStorage();

  late double latitud = double.parse(box.read('myLatitud').toString());
  late double longitud = double.parse(box.read('myLongitud').toString());
  double radio = 100.0;
  String address = "Mi dirección";
  String numEncontrados = "0";

  var circleMarkers = <CircleMarker>[];

  @override
  void initState() {
    myLocation();
    super.initState();
    mapController = MapController();
  }

  void myInit() async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Authorization": "ipue ${box.read('token')}",
      };

      var url = Uri.parse("${IpueColors.urlHost}/getIglesias.php");
      var response = await http.get(url, headers: headers);
      var decodeJson = jsonDecode(response.body);

      circleMarkers = [
        CircleMarker(
            point: LatLng(latitud, longitud),
            color: IpueColors.cPrimario.withOpacity(.5),
            borderStrokeWidth: 1,
            borderColor: IpueColors.cSecundario,
            useRadiusInMeter: true,
            radius: double.parse("5000") // radio // 2000 meters | 2 km
            ),
      ];

      setState(() {
        listaIglesias = IglesiasModel.fromJson(decodeJson);
        numEncontrados = listaIglesias.iglesias!.length.toString();
      });
    } finally {
      // _myLocation();
    }
  }

  void myLocation() async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Authorization": "ipue ${box.read('token')}",
      };

      String distancia = "100";

      var url = Uri.parse(
          "${IpueColors.urlHost}/getIglesiasUsers.php?lat=${box.read('myLatitud').toString()}&log=${box.read('myLongitud').toString()}&distancia=$distancia");
      var response = await http.get(url, headers: headers);
      var decodeJson = jsonDecode(response.body);

      circleMarkers = [
        CircleMarker(
            point: LatLng(latitud, longitud),
            color: IpueColors.cPrimario.withOpacity(.5),
            borderStrokeWidth: 1,
            borderColor: IpueColors.cSecundario,
            useRadiusInMeter: true,
            radius: double.parse("5000") // radio // 2000 meters | 2 km
            ),
      ];

      setState(() {
        listaIglesias = IglesiasModel.fromJson(decodeJson);
        numEncontrados = listaIglesias.iglesias!.length.toString();
      });
    } finally {
      // _myLocation();
    }
  }

  void mybuscador(String busqueda) async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Authorization": "ipue ${box.read('token')}",
      };

      String distancia = "5";

      var url = Uri.parse(
          "${IpueColors.urlHost}/getIglesiasSearch.php?texto=$busqueda");
      var response = await http.get(url, headers: headers);
      var decodeJson = jsonDecode(response.body);

      circleMarkers = [
        CircleMarker(
            point: LatLng(latitud, longitud),
            color: IpueColors.cPrimario.withOpacity(.5),
            borderStrokeWidth: 1,
            borderColor: IpueColors.cSecundario,
            useRadiusInMeter: true,
            radius: double.parse("5000") // radio // 2000 meters | 2 km
            ),
      ];

      setState(() {
        listaIglesias = IglesiasModel.fromJson(decodeJson);
        numEncontrados = listaIglesias.iglesias!.length.toString();
      });
    } finally {
      // _myLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _panelMap(),
          _panelSearch(),
          _panelIglesias(),
        ],
      ),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _myLocation() {
    setState(() {
      latitud = double.parse(box.read('myLatitud').toString());
      longitud = double.parse(box.read('myLongitud').toString());
      mapController.move(LatLng(latitud, longitud), 4);
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  /* ++++++++++++++++++++++++++++++++++++++++ */

  Widget _panelMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(latitud, longitud),
        zoom: 10,
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'IPUE',
          onSourceTapped: null,
        ),
      ],
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.fericor.ipue',

          /*urlTemplate:
              "https://api.mapbox.com/styles/v1/fericor/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
          additionalOptions: const {
            'mapStyleId': AppConstants.mapBoxStyleId,
            'accessToken': AppConstants.mapBoxAccessToken,
          },*/
        ),
        CircleLayer(
          circles: circleMarkers,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(latitud, longitud),
              builder: (_) {
                return const Icon(
                  Icons.person_pin_circle,
                  color: IpueColors.cPrimario,
                  size: 50.0,
                );
              },
            ),
            for (int i = 0; i < listaIglesias.iglesias!.length; i++)
              Marker(
                height: 70,
                width: 70,
                point: LatLng(listaIglesias.iglesias![i].latitud!,
                    listaIglesias.iglesias![i].longitud!),
                builder: (_) {
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: SizedBox(
                          height: 200,
                          child: Column(
                            children: [
                              Text(
                                  listaIglesias.iglesias![i].titulo.toString()),
                              Text(listaIglesias.iglesias![i].descripcion
                                  .toString()),
                            ],
                          ),
                        ),
                      ));
                      pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                      selectedIndex = i;
                      _animatedMapMove(
                          LatLng(listaIglesias.iglesias![i].latitud!,
                              listaIglesias.iglesias![i].longitud!),
                          11.5);
                      setState(() {});
                    },
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: selectedIndex == i ? 1 : 0.7,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: selectedIndex == i ? 1 : 0.5,
                        child: Image.network(
                          "${IpueColors.urlHost}/images/logos/logo_${listaIglesias.iglesias![i].id.toString()}.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _panelSearch() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(10.0, 15.0),
              blurRadius: 35.0,
            ),
          ],
          color: IpueColors.cPrimario,
          borderRadius: BorderRadius.all(
            Radius.circular(
              10.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            top: 0,
            bottom: 0,
            right: 8.0,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.pop(context);
                },
                child: const Icon(
                  // Icons.arrow_back,
                  Icons.search,
                  color: IpueColors.cBlanco,
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    mybuscador(value);
                  },
                  style: const TextStyle(color: IpueColors.cBlanco),
                  controller: controlBuscar,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.only(left: 15, bottom: 0, top: 0, right: 15),
                    hintText: "Buscar iglesias cercanas",
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _myLocation();
                },
                child: const Icon(
                  Icons.my_location_outlined,
                  color: IpueColors.cBlanco,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelIglesias() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      height: MediaQuery.of(context).size.height * 0.31,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (value) {
          selectedIndex = value;
          _animatedMapMove(
              LatLng(listaIglesias.iglesias![value].latitud!,
                  listaIglesias.iglesias![value].longitud!),
              11.5);
          setState(() {});
        },
        itemCount: listaIglesias.iglesias!.length,
        itemBuilder: (_, index) {
          final item = listaIglesias.iglesias![index];
          return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          "${IpueColors.urlHost}/images/iglesias/iglesia_${item.id}.png"),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${item.ciudad}, ${item.provincia}",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // PARTE DOS
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            left: 15.0,
                            right: 15.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.titulo!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: IpueColors.cBlanco,
                                      ),
                                    ),
                                    Text(
                                      item.direccion!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: IpueColors.cBlanco,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _launchInBrowser(
                                                Uri.parse(item.web!));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: IpueColors.cPrimario,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: const Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Icon(
                                                Icons.link,
                                                size: 25.0,
                                                color: IpueColors.cBlanco,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _launchInBrowser(Uri.parse(
                                                "http://maps.google.com/maps?saddr=$latitud,$longitud&daddr=${item.latitud},${item.longitud}"));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: IpueColors.cPrimario,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: const Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Icon(
                                                Icons.map,
                                                size: 25.0,
                                                color: IpueColors.cBlanco,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _makePhoneCall(item.telefono!);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: IpueColors.cPrimario,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: const Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Icon(
                                                Icons.phone,
                                                size: 25.0,
                                                color: IpueColors.cBlanco,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellowAccent,
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    "4.0",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
  /* ++++++++++++++++++++++++++++++++++++++++ */
}

class ItemModel {
  String title;
  IconData icon;

  ItemModel(this.title, this.icon);
}
