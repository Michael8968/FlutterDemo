import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final Function(String) onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name[0].toUpperCase()),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => onDelete(user.id),
        ),
      ),
    );
  }
}

