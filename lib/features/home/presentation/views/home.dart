import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/core/shared/widgets/publish_property.dart';
import 'package:flutter_application_1/features/home/presentation/views/minhas_marcacoes_screen.dart';
import 'package:flutter_application_1/features/favorites/presentation/views/favorite.dart';
import 'package:flutter_application_1/features/home/presentation/views/offers.dart';
import 'package:flutter_application_1/features/profile/presentation/views/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> homeScreens = const [
    OffersView(),
    MinhasMarcacoesScreen(),
    FavoriteView(),
    ProfileView(),
  ];
  int currentIndex = 0;

  void _onFabPressed() {
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
    print('HomeScreen building - currentIndex: $currentIndex');
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: homeScreens),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
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
              _buildNavItem(CupertinoIcons.house_alt, "Ofertas", 0),
              _buildNavItem(CupertinoIcons.calendar, "Marcações", 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(CupertinoIcons.heart, "Favoritos", 2),
              _buildNavItem(CupertinoIcons.person, "Meu Perfil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
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
                color: currentIndex == index
                    ? AppColors.primary
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
