import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizreview/provider/bizprovider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Bizprovider>(context, listen: false).initialzeEditProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bizprovider = Provider.of<Bizprovider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.teal.shade800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Form(
              key: bizprovider.editProfileFormKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => bizprovider.updateProfileImage(context),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: bizprovider.profileImageBytes != null
                              ? MemoryImage(bizprovider.profileImageBytes!)
                              : (user?.photoURL != null
                                    ? NetworkImage(user!.photoURL!)
                                    : null),
                          child: bizprovider.isUploadingImage
                              ? CircularProgressIndicator(
                                  color: Colors.teal,
                                  strokeWidth: 3,
                                )
                              : (bizprovider.profileImageBytes == null &&
                                        user?.photoURL == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.teal.shade800,
                                      )
                                    : null),
                        ),
                        if (!bizprovider.isUploadingImage)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade800,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter valid Username";
                      } else if (value.toString().length < 5) {
                        return "Username is too small";
                      }
                      return null;
                    },
                    controller: bizprovider.editUsernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Email";
                      } else if (!(value.toString().contains('@'))) {
                        return "Invalid Email";
                      }
                      return null;
                    },
                    controller: bizprovider.editEmailController,
                    enabled: false, //read only
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: bizprovider.isSavingProfile
                            ? null
                            : () {
                                if (bizprovider.editProfileFormValidator()) {
                                  bizprovider.saveProfileChanges(context);
                                }
                              },
                        child: bizprovider.isSavingProfile
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors
                                          .black, // Spinner black to match text
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Saving...",
                                    // style: Theme.of(context)
                                    //     .textTheme
                                    //     .bodyMedium
                                    //     ?.copyWith(
                                    //       color: Colors
                                    //           .black, // <-- Keep black text
                                    //       fontWeight: FontWeight.w600,
                                    //     ),
                                  ),
                                ],
                              )
                            : Text("Save"),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
