import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/colors.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    this.label,
    this.placeholder,
    this.iconUri,
    this.iconSize = 14,
    required this.controller,
    required this.isPassword,
  });

  final String? label;
  final String? placeholder;
  final String? iconUri;
  final double? iconSize;
  final TextEditingController controller;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.grey.shade100,
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1,
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey.shade300,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1,
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: AppColors.primary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Visibility(
                    visible: iconUri != null,
                    child: Padding(
                      padding: EdgeInsets.all((1 / (iconSize ?? 14)) * 80),
                      child: Visibility(
                        visible: iconUri != null,
                        replacement: const SizedBox(),
                        child: Image(
                          image: AssetImage(iconUri!),
                          height: iconSize ?? 14,
                          width: iconSize ?? 14,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
