import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/home/data/models/property.dart';

class PropertySubmitionSummary extends StatefulWidget {
  const PropertySubmitionSummary({super.key});

  @override
  State<PropertySubmitionSummary> createState() =>
      _PropertySubmitionSummaryState();
}

class _PropertySubmitionSummaryState extends State<PropertySubmitionSummary> {
  final ButtonStyle selectedButtonStyle = TextButton.styleFrom(
    backgroundColor: const Color(0xFF333333),
    minimumSize: Size(100, 0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
    ),
  );

  final ButtonStyle unselectedButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.white,
    minimumSize: Size(100, 0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
    ),
  );

  int selectedCredit = 0;
  final visibility = [
    {"Basico": 1},
    {"Premium": 5},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final property = properties[0];
    return Container(
      width: double.infinity,
      height: screenHeight * 0.92,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
                const Spacer(),
                Text(
                  "Publicar Propriedade",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildSummaryItem("Titulo", property.title),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem("Endereço", property.location),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem("Preço", "${property.price}MT"),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem(
                    "Categoria",
                    property.type.toString().split(".")[1],
                  ),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem(
                    "Quartos",
                    property.attributes[PropertyAttributeType.room].toString(),
                  ),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem(
                    "Banheiros",
                    property.attributes[PropertyAttributeType.wc].toString(),
                  ),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem(
                    "Estacionamento",
                    property.attributes[PropertyAttributeType.parking]
                        .toString(),
                  ),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem("Contactos", "+258 85 763 4079"),
                  const Divider(color: Colors.black45),
                  _buildSummaryItem(
                    "Contactos",
                    "Lorem ipsum dolor sit amet, conse...",
                  ),
                ],
              ),
            ),
            const Spacer(),

            Row(
              children: [
                Text(
                  "Visibilidade",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  "Creditos",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const DottedLine(),
            const SizedBox(height: 8 * 1),
            Column(
              children: visibility.map((v) {
                final idx = visibility.indexOf(v);
                return Row(
                  children: [
                    Text(
                      v.keys.first,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (idx != selectedCredit) {
                            selectedCredit = idx;
                          }
                        });
                      },
                      style: selectedCredit == idx
                          ? selectedButtonStyle
                          : unselectedButtonStyle,
                      child: Text(
                        "${v.values.last} Credito${v.values.last > 1 ? 's' : ''}",
                        style: TextStyle(
                          color: selectedCredit == idx
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      " /dia",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Continuar",
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
      ),
    );
  }

  Widget _buildSummaryItem(String key, String value) {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          Text(
            key,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
