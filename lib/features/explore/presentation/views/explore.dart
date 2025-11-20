import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/shared/widgets/property_attribure.dart';
import 'package:flutter_application_1/features/home/data/models/property.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final LatLng _initialCameraPosition = const LatLng(
    -25.955582410694454,
    32.59946372579154,
  );
  bool _isExpandedCard = false;
  Property? _selectedProperty;
  bool _isContainerVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the first property to show the container on startup
    _selectedProperty = properties[0];
    _isContainerVisible = true;
  }

  Set<Marker> _createMarkers() {
    return properties.map((property) {
      return Marker(
        markerId: MarkerId(property.id),
        position: LatLng(
          property.position.latitude,
          property.position.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getHueForPropertyType(property.type),
        ), // Blue hue
        // OR use a custom icon asset:
        // icon: BitmapDescriptor.fromAssetImage(
        //   const ImageConfiguration(size: Size(48, 48)),
        //   AppImages.locationIcon,
        // ),
        onTap: () {
          setState(() {
            _selectedProperty = property;
            _isExpandedCard = false;
            _isContainerVisible = true;
          });
        },
      );
    }).toSet();
  }

  double _getHueForPropertyType(PropertyType type) {
    switch (type) {
      case PropertyType.land:
        return BitmapDescriptor.hueGreen;
      case PropertyType.rent:
        return BitmapDescriptor.hueBlue;
      case PropertyType.house:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<Set<Marker>>(
            // FutureBuilder to build markers with custom icons
            future: _buildMarkersWithIcons(),
            builder: (BuildContext context, AsyncSnapshot<Set<Marker>> snapshot) {
              Set<Marker> markers =
                  snapshot.data ??
                  _createMarkers(); // Fallback to default markers during loading
              return GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _initialCameraPosition,
                  zoom: 12,
                ),
                markers: markers,
              );
            },
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isContainerVisible ? 0 : -screenHeight * 0.4,
            left: 0,
            right: 0,
            height: _isExpandedCard ? screenHeight * 0.8 : 160,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_isExpandedCard ? 30 : 10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, 0),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isContainerVisible
                  ? _isExpandedCard
                        ? buildExpandedCardContent(_selectedProperty!)
                        : buildCollapsedCardContent(_selectedProperty!)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Future<Set<Marker>> _buildMarkersWithIcons() async {
    Set<Marker> markers = {};
    for (var property in properties) {
      // Use property.imageAsset instead of AppImages.beachHouse
      BitmapDescriptor customIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        AppIcons.locationPin,
      );
      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          icon: customIcon,
          position: LatLng(
            property.position.latitude,
            property.position.longitude,
          ),
          onTap: () {
            setState(() {
              _selectedProperty = property;
              _isExpandedCard = false;
              _isContainerVisible = true;
            });
          },
        ),
      );
    }
    return markers;
  }

  Widget buildCollapsedCardContent(Property property) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const Image(
            image: AssetImage(AppImages.beachHouse),
            width: 120,
            height: 130,
            fit: BoxFit.fitHeight,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "MZN ${property.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: property.type == PropertyType.rent ? "/mês" : "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      property.location,
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 12,
                  runSpacing: 5.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: property.attributes.entries
                      .map((el) {
                        return renderPropertyAttribute(el, size: 1.3);
                      })
                      .toList()
                      .sublist(0, property.attributes.entries.length - 2),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isExpandedCard = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      minimumSize: const Size(double.maxFinite, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Ver Detalhes",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildExpandedCardContent(Property property) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: const Image(
              image: AssetImage(AppImages.beachHouse),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  property.type == PropertyType.rent ? "Arrenda-se" : "Terreno",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "MZN ${property.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: property.type == PropertyType.rent ? "/mês" : "",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 14),
                const SizedBox(width: 4),
                Text(
                  property.location,
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 12,
              runSpacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: property.attributes.entries.map((el) {
                return renderPropertyAttribute(el, size: 1.5);
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(property.description, style: const TextStyle()),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isExpandedCard = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF333333),
                minimumSize: const Size(double.maxFinite, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Ver Detalhes",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
