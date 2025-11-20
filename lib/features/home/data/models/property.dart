import 'package:equatable/equatable.dart';

enum PropertyType { land, rent, house }

enum PropertyAttributeType { room, wc, pool, parking, width, length }

class PropertyLocation {
  final double latitude;
  final double longitude;

  const PropertyLocation(this.latitude, this.longitude);
}

class Property extends Equatable {
  final String id;
  final double price;
  final String location;
  final String title;
  final PropertyType type;
  final Map<PropertyAttributeType, int> attributes;
  final bool active;
  final PropertyLocation position;
  final String description; // Added description field

  const Property({
    required this.id,
    required this.price,
    required this.title,
    required this.location,
    required this.type,
    required this.attributes,
    required this.active,
    required this.position,
    required this.description,
  });

  @override
  List<Object?> get props => [id];
}

const quickOptions = ["Arrendar", "Comprar", "Terreno", "Casas"];

final List<Property> properties = [
  // Ponta do Ouro
  const Property(
    id: "5",
    price: 8500000,
    title: "Beachfront House in Ponta do Ouro",
    location: "Ponta do Ouro, Maputo",
    type: PropertyType.house,
    attributes: {
      PropertyAttributeType.room: 4,
      PropertyAttributeType.wc: 3,
      PropertyAttributeType.pool: 1,
      PropertyAttributeType.parking: 2,
    },
    active: true,
    position: PropertyLocation(-26.8455, 32.8910),
    description:
        "Escape to paradise in this stunning beachfront house in Ponta do Ouro. Wake up to the sound of the waves and enjoy direct access to the pristine sands. Perfect for families or groups seeking a luxurious coastal getaway.",
  ),
  const Property(
    id: "6",
    price: 12000000,
    title: "Luxury Villa with Ocean Views",
    location: "Ponta do Ouro, Maputo",
    type: PropertyType.house,
    attributes: {
      PropertyAttributeType.room: 5,
      PropertyAttributeType.wc: 4,
      PropertyAttributeType.pool: 1,
      PropertyAttributeType.parking: 3,
    },
    active: true,
    position: PropertyLocation(-26.8465, 32.8920),
    description:
        "Indulge in the ultimate luxury experience at this magnificent villa boasting breathtaking ocean views. Relax by your private pool, entertain in style, and savor the tranquility of Ponta do Ouro from this exceptional residence.",
  ),

  // Tofo
  const Property(
    id: "7",
    price: 6000000,
    title: "Tofo Beach House",
    location: "Tofo, Inhambane",
    type: PropertyType.house,
    attributes: {
      PropertyAttributeType.room: 3,
      PropertyAttributeType.wc: 2,
      PropertyAttributeType.parking: 1,
    },
    active: true,
    position: PropertyLocation(-23.8650, 35.5417),
    description:
        "Discover your dream beach house in Tofo, a charming coastal town known for its diving and surf spots. This cozy house is steps away from the beach, ideal for those seeking an adventurous and laid-back lifestyle.",
  ),
  const Property(
    id: "8",
    price: 2500000,
    title: "Tofo Apartment Rental",
    location: "Tofo, Inhambane",
    type: PropertyType.rent,
    attributes: {PropertyAttributeType.room: 2, PropertyAttributeType.wc: 1},
    active: true,
    position: PropertyLocation(-23.8640, 35.5427),
    description:
        "Experience the vibrant Tofo atmosphere from this comfortable apartment rental. Perfect for couples or small families, this rental offers easy access to the beach, restaurants, and all the excitement Tofo has to offer.",
  ),

  // Bilene
  const Property(
    id: "9",
    price: 9000000,
    title: "Bilene Lagoon Front Villa",
    location: "Bilene, Gaza",
    type: PropertyType.house,
    attributes: {
      PropertyAttributeType.room: 4,
      PropertyAttributeType.wc: 3,
      PropertyAttributeType.pool: 1,
      PropertyAttributeType.parking: 2,
    },
    active: true,
    position: PropertyLocation(-24.5267, 34.7000),
    description:
        "Unwind in style at this exquisite lagoon front villa in Bilene. Enjoy breathtaking views of the tranquil lagoon, swim in your private pool, and create unforgettable memories in this Bilene gem.",
  ),
  const Property(
    id: "10",
    price: 4000000,
    title: "Bilene Holiday Home",
    location: "Bilene, Gaza",
    type: PropertyType.house,
    attributes: {
      PropertyAttributeType.room: 3,
      PropertyAttributeType.wc: 2,
      PropertyAttributeType.parking: 1,
    },
    active: true,
    position: PropertyLocation(-24.5257, 34.7010),
    description:
        "Your perfect family holiday starts here at this charming Bilene holiday home. Nestled in a peaceful area of Bilene, this house offers a relaxing escape with easy access to the lagoon and local amenities.",
  ),
];
