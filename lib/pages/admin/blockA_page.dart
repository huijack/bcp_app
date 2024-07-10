import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockAPage extends StatelessWidget {
  const BlockAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBuilding(
      buildingName: 'Block A',
      equipmentOrder: [
        'Projector',
        'Air Conditioner',
        'Fan',
        'Light',
        'Door',
        'Others',
      ],
    );
  }
}