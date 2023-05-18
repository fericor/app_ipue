import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart'; // Only import if required functionality is not exposed by 'flutter_map.dart'
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_ipue/models/iglesias_model.dart';
import 'package:app_ipue/utilities/styles_utils.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  TextEditingController controlBuscar = TextEditingController();
  IglesiasModel listaIglesias =
      IglesiasModel.fromJson({"error": true, "iglesias": []});

  late final MapController mapController;
  final box = GetStorage();

  late double latitud = 0;
  late double longitud = 0;
  String address = "Mi dirección";
  String numEncontrados = "0";

  late List<Marker> markers = [];

  @override
  void initState() {
    myInit();
    super.initState();
    mapController = MapController();
  }

  void myInit() async {
    try {
      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${box.read('token')}",
      };

      var url = Uri.parse('${IpueColors.urlHost}/getIglesias.php');
      var response = await http.get(url, headers: headers);
      var decodeJson = jsonDecode(response.body);

      setState(() {
        listaIglesias = IglesiasModel.fromJson(decodeJson);
        numEncontrados = listaIglesias.iglesias!.length.toString();

        latitud = double.parse(box.read('myLatitud').toString());
        longitud = double.parse(box.read('myLongitud').toString());
        address = box.read('myAddress').toString();

        markers = [
          Marker(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 70,
            width: 70,
            point: LatLng(latitud, longitud),
            builder: (ctx) => _markerItemMe(),
          ),
        ];

        for (var element in listaIglesias.iglesias!) {
          markers.add(
            Marker(
              anchorPos: AnchorPos.align(AnchorAlign.center),
              height: 80,
              width: 80,
              point: LatLng(
                element.latitud!,
                element.longitud!,
              ),
              builder: (ctx) => _markerItem(element.id.toString()!),
            ),
          );
        }

        mapController.move(LatLng(latitud, longitud), 10.0);
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _panelMap(),
          _panelSearch(),
          _panelBottom(listaIglesias.iglesias!),
        ],
      ),
    );
  }

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  void _openPopupMap(double latitud, longitut) {
    mapController.center.latitude = latitud;
    mapController.center.longitude = longitut;
    // (LatLng(latitud, longitud));
  }
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

  ///////////////////////////
  Widget _panelMap() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(latitud, longitud),
          zoom: 13.0,
          maxZoom: 19.0,
        ),
        nonRotatedChildren: [
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: null,
          ),
        ],
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            // urlTemplate: 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              spiderfyCircleRadius: 30,
              spiderfySpiralDistanceMultiplier: 2,
              circleSpiralSwitchover: 12,
              maxClusterRadius: 20,
              rotate: true,
              anchor: AnchorPos.align(AnchorAlign.center),
              fitBoundsOptions: const FitBoundsOptions(
                padding: EdgeInsets.all(50),
                maxZoom: 9,
              ),
              markers: markers,
              polygonOptions: const PolygonOptions(
                  borderColor: IpueColors.cPrimario,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              popupOptions: PopupOptions(
                popupSnap: PopupSnap.markerTop,
                popupBuilder: (_, marker) => Container(
                  height: 300.0,
                  width: 300.0,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 160.0,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                                "${IpueColors.urlHost}/images/iglesias/iglesia_2.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Tabernáculo de fe",
                          style: TextStyle(
                            color: IpueColors.cGris,
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      const Divider(
                        color: IpueColors.cPrimario,
                        height: 10.0,
                        thickness: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: const [
                                Icon(
                                  Icons.web_rounded,
                                  size: 40.0,
                                  color: IpueColors.cPrimario,
                                ),
                                Text(
                                  "Web",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Text("139 m"),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 40.0, right: 40.0),
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.my_location_rounded,
                                    size: 40.0,
                                    color: IpueColors.cPrimario,
                                  ),
                                  Text(
                                    "Como llegar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Text("139 m"),
                                ],
                              ),
                            ),
                            Column(
                              children: const [
                                Icon(
                                  Icons.phone,
                                  size: 40.0,
                                  color: IpueColors.cPrimario,
                                ),
                                Text(
                                  "Llamar",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                popupState: PopupState(),
              ),
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelSearch() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        decoration: const BoxDecoration(
          color: IpueColors.cBlanco,
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
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: IpueColors.cGris,
                ),
              ),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: IpueColors.cGris),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelBottom(List<DataIglesias> data) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: IpueColors.cBlanco,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: const TextStyle(
                  color: IpueColors.cFondo,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$numEncontrados iglesias encontradas",
                    style: const TextStyle(
                      color: IpueColors.cGris,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Ver todos",
                      style: TextStyle(
                        color: IpueColors.cPrimario,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 100.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: data
                      .map<Widget>(
                        (item) => _panelSlideClubes(item),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelSlideClubes(DataIglesias item) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 70.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                  image: NetworkImage(
                      "${IpueColors.urlHost}/images/iglesias/iglesia_${item.id}.png"),
                  fit: BoxFit.cover),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.titulo!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: IpueColors.cGris,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.direccion!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: IpueColors.cGris,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                const Text(
                  "5 km",
                  style: TextStyle(
                    color: IpueColors.cGris,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(
                  height: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rate,
                      color: IpueColors.cPrimario,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "4.4",
                      style: TextStyle(
                        color: IpueColors.cGris,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 40.0,
                    ),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: IpueColors.cPrimario,
                      child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.share_sharp,
                          size: 18.0,
                          color: IpueColors.cPrimario,
                        ),
                        color: IpueColors.cPrimario,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: IpueColors.cPrimario,
                      child: IconButton(
                        onPressed: () =>
                            _openPopupMap(item.latitud!, item.longitud!),
                        icon: const Icon(
                          Icons.location_on,
                          size: 18.0,
                          color: IpueColors.cPrimario,
                        ),
                        color: IpueColors.cPrimario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _markerItemMe() {
    return Container(
        height: 100.0,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/marker_green.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          children: const [
            SizedBox(
              height: 8.0,
            ),
            Icon(
              Icons.person,
              color: IpueColors.cGris,
              size: 30.0,
            ),
          ],
        ));
  }

  Widget _markerItem(String idIglesia) {
    return Image.network(
      "${IpueColors.urlHost}/images/logos/logo_$idIglesia.png?v=1",
      width: 10,
      height: 10,
      fit: BoxFit.contain,
    );
  }

  /////////////////////////
}
