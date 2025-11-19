import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/core/shared/widgets/publish_property.dart';
import 'package:flutter_application_1/features/chat/presentation/views/chat.dart';
import 'package:flutter_application_1/features/favorites/presentation/views/favorite.dart';
import 'package:flutter_application_1/features/home/presentation/views/offers.dart';
import 'package:flutter_application_1/features/profile/presentation/views/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);
    controller.addListener(() {
      setState(() {
        currentIndex = controller.page!.toInt();
      });
    });
  }

  List<Widget> homeScreens = const [
    OffersView(),
    // ExploreView(),
    ChatView(),
    FavoriteView(),
    ProfileView()
  ];
  int currentIndex = 0;

  void _onFabPressed() {
    // Handle FAB press
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
        return const PublishProperty();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: homeScreens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: kBottomNavigationBarHeight + 20,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                 CupertinoIcons.house_alt,  "Ofertas", 0),
              // _buildNavItem(Icons.search, "Explorar", 0),
              _buildNavItem(CupertinoIcons.chat_bubble, "Mensagem", 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(CupertinoIcons.heart, "Favoritos", 3),
              _buildNavItem(CupertinoIcons.person, "Meu Perfil", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => controller.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: currentIndex == index ? AppColors.primary : Colors.black87,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: currentIndex == index ? AppColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}