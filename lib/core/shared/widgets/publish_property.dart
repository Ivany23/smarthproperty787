import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/features/profile/presentation/views/property_submition_summary.dart';

class PublishProperty extends StatefulWidget {
  const PublishProperty({super.key});

  @override
  State<PublishProperty> createState() => _PublishPropertyState();
}

class _PublishPropertyState extends State<PublishProperty> {
  final images = const [AppImages.beachHouse2, AppImages.beachHouse3];
  String? selectedCategory = "Terreno";
  String? selectedParking = "Sim";
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ButtonStyle selectedButtonStyle = TextButton.styleFrom(
    backgroundColor: const Color(0xFF333333),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
    ),
  );

  final ButtonStyle unselectedButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
    ),
  );

  @override
  void dispose() {
    _priceController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.94,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
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
                  fontSize: 16,
                ),
              ),
              const Spacer(),
            ],
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImageSection(),
                  _buildTextFieldSection("Título", TextInputType.text),
                  _buildTextFieldSection(
                    "Endereço",
                    TextInputType.streetAddress,
                  ),
                  _buildCategorySection(),
                  selectedCategory == "Terreno"
                      ? _buildLandSection()
                      : _buildNumberInputSection(),
                  _buildPriceSection(),
                  _buildContactSection(),
                  _buildDescriptionSection(),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return PublishPropertySection(
      title: "Adicionar fotos",
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: images.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Image(
                    image: AssetImage(images[index]),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8D8),
              borderRadius: BorderRadius.circular(5),
              border: Border.fromBorderSide(
                BorderSide(width: 0.9, color: Colors.grey.shade400),
              ),
            ),
            child: Column(
              children: [
                const Spacer(flex: 3),
                const Icon(Icons.camera_alt_outlined, size: 24),
                const Spacer(flex: 2),
                Text("Adicionar fotos", style: const TextStyle(fontSize: 12)),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSection(String title, TextInputType keyboardType) {
    return PublishPropertySection(
      title: title,
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return PublishPropertySection(
      title: "Categoria",
      child: Row(
        children: [
          _buildCategoryButton("Terreno", "Terreno"),
          const SizedBox(width: 10),
          _buildCategoryButton("Arrendar", "Arrendar"),
          const SizedBox(width: 10),
          _buildCategoryButton("A Venda", "A Venda"),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, String value) {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => selectedCategory = value),
        style: selectedCategory == value
            ? selectedButtonStyle
            : unselectedButtonStyle,
        child: Text(
          label,
          style: TextStyle(
            color: selectedCategory == value ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLandSection() {
    return Row(
      children: [
        _buildNumberField("Largura(M)", size: 100),
        const SizedBox(width: 10),
        _buildNumberField("Comprimento(M)", size: 140),
      ],
    );
  }

  Widget _buildNumberInputSection() {
    return Row(
      children: [
        _buildNumberField("Quartos"),
        const SizedBox(width: 20),
        _buildNumberField("Banheiros"),
        const SizedBox(width: 20),
        Expanded(
          child: PublishPropertySection(
            title: "Estacionamento",
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => selectedParking = "Sim"),
                    style: _parkingButtonStyle("Sim"),
                    child: Text(
                      "Sim",
                      style: TextStyle(
                        color: selectedParking == "Sim"
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => selectedParking = "Não"),
                    style: _parkingButtonStyle("Não"),
                    child: Text(
                      "Não",
                      style: TextStyle(
                        color: selectedParking == "Não"
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _parkingButtonStyle(String value) {
    return TextButton.styleFrom(
      backgroundColor: selectedParking == value
          ? const Color(0xFF333333)
          : Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
        borderRadius: value == "Sim"
            ? const BorderRadius.horizontal(left: Radius.circular(10))
            : const BorderRadius.horizontal(right: Radius.circular(10)),
      ),
      minimumSize: const Size(0, 55),
    );
  }

  Widget _buildNumberField(String title, {double size = 80}) {
    return SizedBox(
      width: size,
      child: PublishPropertySection(
        title: title,
        child: TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return PublishPropertySection(
      title: "Preço",
      child: TextField(
        controller: _priceController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          suffixText: "MT",
          suffixStyle: const TextStyle(fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return PublishPropertySection(
      title: "Contactos",
      child: TextField(
        controller: _contactController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixText: "+258 ",
          prefixStyle: const TextStyle(fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return PublishPropertySection(
      title: "Descrição",
      child: TextField(
        controller: _descriptionController,
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        minLines: 4,
        decoration: InputDecoration(
          hintText: "Descreva a propriedade em detalhes...",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Color(0xFFA6A6A6)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          // Handle form submission
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            builder: (context) {
              return const PropertySubmitionSummary();
            },
          );
        },
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
    );
  }
}

class PublishPropertySection extends StatelessWidget {
  const PublishPropertySection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
