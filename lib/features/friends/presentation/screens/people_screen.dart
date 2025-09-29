import 'package:chat_app/features/authentication/presentation/viewmodels/authentication_provider.dart';
import 'package:chat_app/features/friends/presentation/viewmodels/all_people_search_stream.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              placeholder: 'Tìm kiếm',
              onChanged: (value) => setState(() => searchQuery = value),
              onSuffixTap: () {
                setState(() => searchQuery = '');
                FocusScope.of(context).unfocus();
              },
            ),
          ),

          Expanded(
            child: searchQuery.isEmpty
                ? const Center(
                    child: Text(
                      'Tìm mọi người',
                    ),
                  )
                : AllPeopleSearchStream(
                    uid: currentUser.uid,
                    searchText: searchQuery,
                  ),
          ),
        ],
      ),
    ));
  }
}
