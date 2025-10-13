import 'package:bizreview/provider/bizprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  @override
  Widget build(BuildContext context) {
    final addscreenProvider = Provider.of<Bizprovider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Add Business"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: addscreenProvider.addBusinessFormKey,
            child: Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => addscreenProvider.pickBusinessImage(),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: addscreenProvider.isUploadingBusinessImage
                          ? Center(child: CircularProgressIndicator())
                          : addscreenProvider.businessImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                addscreenProvider.businessImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Add Business Image",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: addscreenProvider.businessNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Business Name";
                      } else if (value.length < 3) {
                        return "Minimum length 3 is required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(hintText: "Business Name"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: addscreenProvider.businessAddressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Business Address";
                      } else if (value.length < 3) {
                        return "Minimum length 3 is required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(hintText: "Business Address"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: addscreenProvider.businessPhoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Business Phone";
                      } else if (value.length < 10) {
                        return "Minimum length 10 is required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(hintText: "Business Phone"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: addscreenProvider.businessDescriptionController,
                    maxLines: 7,
                    minLines: 5,
                    maxLength: 300,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Business Description";
                      } else if (value.length < 10) {
                        return "Minimum length 10 is required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Description",
                      alignLabelWithHint: true,
                      hintText: "Write about your business details...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: addscreenProvider.SelectedBusiness,
                    hint: Text("Select Category"),
                    items: addscreenProvider.businessCategories
                        .map<DropdownMenuItem<String>>((
                          String businessCategories,
                        ) {
                          return DropdownMenuItem<String>(
                            value: businessCategories,
                            child: Text(businessCategories),
                          );
                        })
                        .toList(),
                    onChanged: (String? newvalue) {
                      addscreenProvider.dropDownChanged(newvalue!);
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: addscreenProvider.isSavingBusiness
                            ? null
                            : () {
                                if (addscreenProvider
                                    .addBusinessFormValidator()) {
                                  addscreenProvider
                                      .saveBusinessModelwithFormStates(context);
                                }
                              },
                        child: addscreenProvider.isSavingBusiness
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Saving...",
                                    // style: Theme.of(context)
                                    //     .textTheme
                                    //     .bodyMedium
                                    //     ?.copyWith(
                                    //       color: Colors.black,
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
                          addscreenProvider.clearAddBusinessForm();
                          Navigator.pop(context);
                        },
                        child: Text("cancel"),
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
