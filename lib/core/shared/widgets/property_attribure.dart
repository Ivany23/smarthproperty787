import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/features/home/data/models/property.dart';

Widget renderPropertyAttribute(
    MapEntry<PropertyAttributeType, int> attribute, { double size = 1.0 })
{
  String imageUri = "";
  String description = "";
  if (attribute.key == PropertyAttributeType.room) {
    imageUri = AppIcons.bed;
    description = "${attribute.value} Quartos";
  } else if (attribute.key == PropertyAttributeType.wc) {
    imageUri = AppIcons.spa;
    description = "${attribute.value} Casa de banho";
  } else if (attribute.key == PropertyAttributeType.pool) {
    imageUri = AppIcons.pool;
    description = "${attribute.value} Piscina";
  } else if (attribute.key == PropertyAttributeType.parking) {
    imageUri = AppIcons.car;
    description = "${attribute.value} Estacionamento";
  } else if (attribute.key == PropertyAttributeType.width) {
    imageUri = AppIcons.width;
    description = "${attribute.value}M";
  } else if (attribute.key == PropertyAttributeType.length) {
    imageUri = AppIcons.length;
    description = "${attribute.value}M";
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image(
        image: AssetImage(imageUri),
        width: 12 * size,
        height: 12 * size,
      ),
      const SizedBox(
        width: 2,
      ),
      Text(
        description,
        style:  TextStyle(fontSize: size * 8),
      )
    ],
  );
}