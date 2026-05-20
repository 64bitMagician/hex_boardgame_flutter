import 'package:flutter/material.dart';
import 'hex_engine.dart';
import 'player_bst.dart';

// [Documentation State: ___]

class LoginDialog extends StatefulWidget {
  final Player side;
  final PlayerBST playerDB;
  final Function(PlayerProfile) onProfileSelected;

  const LoginDialog({
    Key? key,
    required this.side,
    required this.playerDB,
    required this.onProfileSelected,
  }) : super(key: key);

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  String _searchQuery = "";
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleProfileCreation() {
    String newName = _searchQuery.trim();
    if (newName.isEmpty) return;

    PlayerProfile? existing = widget.playerDB.search(newName);

    if (existing == null) {
      existing = PlayerProfile(name: newName);
      widget.playerDB.insert(existing);
      widget.playerDB.saveTreeToStorage();
    }

    widget.onProfileSelected(existing);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<PlayerProfile> searchResults = widget.playerDB.searchByPrefix(_searchQuery);
    final String sideName = widget.side == Player.red ? 'Red' : 'Blue';

    return AlertDialog(
      title: Text("Select $sideName Player"),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search or Create Name",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final profile = searchResults[index];
                  return ListTile(
                    title: Text(profile.name),
                    subtitle: Text("W: ${profile.wins} | L: ${profile.losses}"),
                    trailing: const Icon(Icons.login),
                    onTap: () {
                      widget.onProfileSelected(profile);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _searchQuery.trim().isEmpty ? null : _handleProfileCreation,
          child: const Text("Create New Profile"),
        )
      ],
    );
  }
}