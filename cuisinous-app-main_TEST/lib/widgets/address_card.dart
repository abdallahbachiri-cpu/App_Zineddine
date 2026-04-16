import 'package:cuisinous/data/models/picked_location.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final PickedLocation location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.location,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(location.street ?? 'Unknown Street'),
        subtitle: Text(
          [
            location.city,
            location.state,
            location.zipCode,
          ].where((s) => s?.isNotEmpty ?? false).join(', '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
