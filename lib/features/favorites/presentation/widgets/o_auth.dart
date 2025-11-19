
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/colors.dart';

import '../../../../core/constants/assets.dart';

class OAuth extends StatelessWidget {
  const OAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Divider(
                  color: AppColors.general,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: const Text("Or"),
                )
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onGoogleSignIn,
                  style: TextButton.styleFrom(
                      minimumSize: const Size(0, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(
                              width: 1, color: Colors.grey.shade400))),
                  icon: const Image(
                    image: AssetImage(AppIcons.google),
                    fit: BoxFit.contain,
                    width: 16 * 1.4,
                  ),
                  label: Text(
                    "Log In with Google",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onFacebookSignIn,
                  style: TextButton.styleFrom(
                      minimumSize: const Size(0, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(
                              width: 1, color: Colors.grey.shade400))),
                  icon: const Image(
                    image: AssetImage(AppIcons.facebook),
                    fit: BoxFit.contain,
                    width: 16 * 1.4,
                  ),
                  label: Text(
                    "Log In with Facebook",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onGoogleSignIn() async{
  }
  void onFacebookSignIn() async{
  }
}
