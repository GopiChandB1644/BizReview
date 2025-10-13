import 'package:bizreview/provider/bizprovider.dart';
import 'package:bizreview/screens/my_reviews_screen.dart';
import 'package:bizreview/screens/profile_edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  @override
  void initState() {
    super.initState();
    // Load profile image when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Bizprovider>(context, listen: false).loadProfileImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bizProvider = Provider.of<Bizprovider>(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.tealAccent.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              bizProvider.userDisplayName ?? user?.displayName ?? "User Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? "user@gmail.com"),
            currentAccountPicture:
                //GestureDetector(
                //onTap: () => bizProvider.updateProfileImage(context),
                //child:
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage: bizProvider.profileImageBytes != null
                          ? MemoryImage(bizProvider.profileImageBytes!)
                          : (user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null),
                      child:
                          // bizProvider.isUploadingImage
                          //     ? CircularProgressIndicator(
                          //         color: Colors.teal,
                          //         strokeWidth: 3,
                          //       )
                          //     : (
                          bizProvider.profileImageBytes == null &&
                              user?.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.teal.shade800,
                            )
                          : null,
                    ),
                    //),
                    // if (!bizProvider.isUploadingImage)
                    //   Positioned(
                    //     bottom: 2,
                    //     right: 2,
                    //     child: Container(
                    //       padding: EdgeInsets.all(6),
                    //       decoration: BoxDecoration(
                    //         color: Colors.teal.shade800,
                    //         shape: BoxShape.circle,
                    //         border: Border.all(color: Colors.white, width: 2),
                    //       ),
                    //       child: Icon(
                    //         Icons.camera_alt,
                    //         size: 14,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
          ),
          //),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Edit Profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.rate_review),
                  title: Text('My Reviews'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyReviewsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final result = await bizProvider.logout(context);
                    if (context.mounted && result != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result)));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
