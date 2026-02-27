import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../data/models/app_user.dart';
import 'edit_immunities_screen.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _searchCtrl = TextEditingController();
  AppUser? _user;

  Future<void> _search() async {
    final result = await FirestoreService.instance.getUser(
      _searchCtrl.text.trim(),
    );
    setState(() => _user = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search User")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(labelText: "Enter User ID"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _search, child: const Text("Search")),
            const SizedBox(height: 20),
            if (_user != null)
              ListTile(
                title: Text(_user!.name),
                subtitle: Text(
                  "Member: ${_user!.membershipActive ? "Yes" : "No"}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditImmunitiesScreen(user: _user!),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
